param(
    [ValidateSet("all", "validate", "deps", "bootstrap", "refresh", "sync", "status", "argo-ui", "app-port", "k6")]
    [string]$Mode = "all",

    [switch]$SkipImageBuild,
    [switch]$SkipPrometheusCrds,
    [switch]$SkipRolloutsInstall,
    [string]$ImageTag = "w8-announcement-app:0.1.1"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
Set-Location $RepoRoot

function Invoke-Logged {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "==> $Title" -ForegroundColor Cyan
    & $Command
}

function Invoke-OptionalLogged {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "==> $Title" -ForegroundColor Cyan
    try {
        & $Command
    }
    catch {
        Write-Host "Skipped: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Test-CommandAvailable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Ensure-Namespace {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    & kubectl get namespace $Name *> $null
    if ($LASTEXITCODE -ne 0) {
        & kubectl create namespace $Name
    }
    else {
        Write-Host "Namespace '$Name' already exists."
    }
}

function Invoke-ValidateManifests {
    Invoke-Logged "Render W8 baseline manifests" {
        kubectl kustomize cloud/w8/day-2/manifests | Out-Null
    }

    Invoke-Logged "Render W9 platform overlay" {
        kubectl kustomize cloud/w9/lab/platform | Out-Null
    }

    Invoke-Logged "Render W9 observability overlay" {
        kubectl kustomize cloud/w9/lab/observability | Out-Null
    }

    Invoke-Logged "Render W9 rollout overlay" {
        kubectl kustomize cloud/w9/lab/rollout | Out-Null
    }
}

function Invoke-BuildAndLoadImage {
    if ($SkipImageBuild) {
        Write-Host "Skipping Docker build and minikube image load."
        return
    }

    Test-CommandAvailable docker
    Test-CommandAvailable minikube

    Invoke-Logged "Build W8 announcement app image" {
        docker build -t $ImageTag cloud/w8/day-2/app
    }

    $context = (& kubectl config current-context).Trim()
    if ($context -eq "minikube") {
        Invoke-Logged "Load W8 image into minikube" {
            minikube image load $ImageTag
        }
    }
    else {
        Write-Host "Current context is '$context'; Docker Desktop Kubernetes can use the locally built Docker image directly."
    }
}

function Invoke-InstallArgoCd {
    Invoke-Logged "Install or verify Argo CD namespace" {
        Ensure-Namespace "argocd"
    }

    Invoke-Logged "Apply Argo CD install manifests" {
        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    }

    Invoke-Logged "Wait for Argo CD server" {
        kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=180s
    }
}

function Invoke-InstallPrometheusCrds {
    if ($SkipPrometheusCrds) {
        Write-Host "Skipping Prometheus Operator CRDs install."
        return
    }

    Invoke-Logged "Install Prometheus Operator CRDs for PrometheusRule" {
        kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/latest/download/stripped-down-crds.yaml
    }

    Invoke-Logged "Wait for PrometheusRule CRD" {
        kubectl wait --for=condition=Established crd/prometheusrules.monitoring.coreos.com --timeout=180s
    }
}

function Invoke-InstallArgoRollouts {
    if ($SkipRolloutsInstall) {
        Write-Host "Skipping Argo Rollouts install."
        return
    }

    Invoke-Logged "Install or verify Argo Rollouts namespace" {
        Ensure-Namespace "argo-rollouts"
    }

    Invoke-Logged "Apply Argo Rollouts install manifests" {
        kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
    }

    Invoke-Logged "Wait for Argo Rollouts CRDs" {
        kubectl wait --for=condition=Established crd/rollouts.argoproj.io --timeout=180s
        kubectl wait --for=condition=Established crd/analysistemplates.argoproj.io --timeout=180s
    }

    Invoke-Logged "Wait for Argo Rollouts controller" {
        kubectl wait --for=condition=available deployment/argo-rollouts -n argo-rollouts --timeout=180s
    }
}

function Invoke-InstallLabDependencies {
    Invoke-InstallPrometheusCrds
    Invoke-InstallArgoRollouts
}

function Invoke-ApplyRootApp {
    Invoke-Logged "Apply W9 Argo CD root app" {
        kubectl apply -f cloud/w9/day-a/argocd/app-of-apps.yaml
    }

    Invoke-Logged "Force refresh root app" {
        kubectl annotate application w9-root -n argocd argocd.argoproj.io/refresh=hard --overwrite
    }
}

function Invoke-RefreshApps {
    Invoke-Logged "Refresh W9 Argo CD apps" {
        $apps = @("w9-root", "w8-platform", "w9-observability", "w9-rollout")
        foreach ($app in $apps) {
            kubectl annotate application $app -n argocd argocd.argoproj.io/refresh=hard --overwrite
        }
    }
}

function Invoke-SyncApps {
    Invoke-Logged "Request Argo CD sync for W9 apps" {
        $apps = @("w9-observability", "w9-rollout", "w9-root")
        foreach ($app in $apps) {
            $patch = @{
                operation = @{
                    sync = @{
                        prune = $true
                        syncStrategy = @{
                            hook = @{}
                        }
                    }
                }
            } | ConvertTo-Json -Depth 10 -Compress

            kubectl patch application $app -n argocd --type merge -p $patch
        }
    }
}

function Invoke-Status {
    Invoke-Logged "Current Kubernetes context" {
        kubectl config current-context
    }

    Invoke-Logged "Cluster namespaces" {
        kubectl get namespace
    }

    Invoke-OptionalLogged "Argo CD applications" {
        kubectl get applications -n argocd
    }

    Invoke-OptionalLogged "W8 platform resources" {
        kubectl get all -n w8-day-2
    }

    Invoke-OptionalLogged "Rollout status" {
        kubectl get rollout announcement-app -n w8-day-2
    }

    Invoke-OptionalLogged "Required lab CRDs" {
        kubectl get crd prometheusrules.monitoring.coreos.com rollouts.argoproj.io analysistemplates.argoproj.io
    }
}

function Invoke-ArgoUiPortForward {
    Write-Host "Opening Argo CD UI tunnel. Keep this terminal open." -ForegroundColor Yellow
    Write-Host "URL: https://localhost:8080"
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}

function Invoke-AppPortForward {
    Write-Host "Opening announcement-service tunnel. Keep this terminal open." -ForegroundColor Yellow
    Write-Host "URL: http://localhost:8080"
    kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
}

function Invoke-K6Smoke {
    Test-CommandAvailable k6

    Invoke-Logged "Run W9 k6 smoke test" {
        k6 run cloud/w9/day-c/load-test/k6-smoke.js
    }
}

Test-CommandAvailable kubectl

switch ($Mode) {
    "validate" {
        Invoke-ValidateManifests
    }
    "deps" {
        Invoke-InstallLabDependencies
    }
    "bootstrap" {
        Invoke-InstallArgoCd
        Invoke-InstallLabDependencies
        Invoke-ApplyRootApp
        Invoke-RefreshApps
        Start-Sleep -Seconds 10
        Invoke-Status
    }
    "refresh" {
        Invoke-RefreshApps
        Invoke-Status
    }
    "sync" {
        Invoke-RefreshApps
        Invoke-SyncApps
        Start-Sleep -Seconds 10
        Invoke-Status
    }
    "status" {
        Invoke-Status
    }
    "argo-ui" {
        Invoke-ArgoUiPortForward
    }
    "app-port" {
        Invoke-AppPortForward
    }
    "k6" {
        Invoke-K6Smoke
    }
    "all" {
        Invoke-Logged "Check cluster connectivity" {
            kubectl cluster-info
        }

        Invoke-BuildAndLoadImage
        Invoke-ValidateManifests
        Invoke-InstallArgoCd
        Invoke-InstallLabDependencies
        Invoke-ApplyRootApp
        Invoke-RefreshApps
        Invoke-SyncApps
        Start-Sleep -Seconds 10
        Invoke-Status

        Write-Host ""
        Write-Host "Next commands:" -ForegroundColor Green
        Write-Host "  .\cloud\w9\scripts\run-gitops-lab.ps1 -Mode sync"
        Write-Host "  .\cloud\w9\scripts\run-gitops-lab.ps1 -Mode refresh"
        Write-Host "  .\cloud\w9\scripts\run-gitops-lab.ps1 -Mode argo-ui"
        Write-Host "  .\cloud\w9\scripts\run-gitops-lab.ps1 -Mode app-port"
        Write-Host "  .\cloud\w9\scripts\run-gitops-lab.ps1 -Mode k6"
        Write-Host ""
        Write-Host "Note: PrometheusRule can sync after CRD install, but live Prometheus analysis still requires a Prometheus server at prometheus-operated.observability.svc.cluster.local:9090."
    }
}
