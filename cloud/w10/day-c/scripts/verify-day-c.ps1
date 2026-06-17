$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$repoRoot = Resolve-Path (Join-Path $root "..\..\..")
$checks = @()

function Add-Check {
    param(
        [string]$Name,
        [bool]$Pass,
        [string]$Detail
    )

    $script:checks += [pscustomobject]@{
        Name = $Name
        Pass = $Pass
        Detail = $Detail
    }
}

function Read-Text {
    param([string]$RelativePath)
    return Get-Content -Raw -LiteralPath (Join-Path $root $RelativePath)
}

function Read-RepoText {
    param([string]$RelativePath)
    return Get-Content -Raw -LiteralPath (Join-Path $repoRoot $RelativePath)
}

function Test-CostLabels {
    param([string]$Text)
    return (($Text -match "owner:\s*platform-team") -and
        ($Text -match "cost-center:\s*training") -and
        ($Text -match "environment:\s*lab"))
}

$requiredFiles = @(
    "README.md",
    "..\..\docs\w10\DAY_C_SCRIPT.md",
    "..\..\docs\w10\day3-platform-runbook-cost-guard.md",
    "guardrails\kustomization.yaml",
    "guardrails\namespace.yaml",
    "guardrails\resource-quota.yaml",
    "guardrails\limit-range.yaml",
    "guardrails\poddisruptionbudget.yaml",
    "guardrails\required-cost-labels-policy.yaml",
    "guardrails\required-cost-labels-binding.yaml",
    "guardrails\deny-loadbalancer-policy.yaml",
    "guardrails\deny-loadbalancer-binding.yaml",
    "integration\w10-day-c-guardrails-app.yaml",
    "runbooks\incident-response.md",
    "runbooks\cost-response.md",
    "tests\workload-missing-cost-labels.yaml",
    "tests\workload-with-cost-labels.yaml",
    "tests\loadbalancer-service-denied.yaml"
)

foreach ($file in $requiredFiles) {
    $path = Join-Path $root $file
    Add-Check "Required file: $file" (Test-Path -LiteralPath $path) $path
}

$quota = Read-Text "guardrails\resource-quota.yaml"
Add-Check "Quota caps LoadBalancer services" ($quota -match "services\.loadbalancers:\s*`"1`"") "services.loadbalancers 1"
Add-Check "Quota caps CPU requests" ($quota -match "requests\.cpu:\s*`"1`"") "requests.cpu 1"
Add-Check "Quota caps memory limits" ($quota -match "limits\.memory:\s*2Gi") "limits.memory 2Gi"

$limitRange = Read-Text "guardrails\limit-range.yaml"
Add-Check "LimitRange sets defaultRequest" ($limitRange -match "defaultRequest:") "defaultRequest present"
Add-Check "LimitRange sets default limits" ($limitRange -match "default:") "default present"
Add-Check "LimitRange sets max limits" ($limitRange -match "max:") "max present"

$pdb = Read-Text "guardrails\poddisruptionbudget.yaml"
Add-Check "PDB keeps one app replica available" (($pdb -match "minAvailable:\s*1") -and ($pdb -match "announcement-app")) "minAvailable 1"

$costPolicy = Read-Text "guardrails\required-cost-labels-policy.yaml"
Add-Check "Cost label policy fails closed" ($costPolicy -match "failurePolicy:\s*Fail") "failurePolicy Fail"
Add-Check "Cost label policy requires owner" ($costPolicy -match "'owner' in object\.metadata\.labels") "owner required"
Add-Check "Cost label policy requires cost-center" ($costPolicy -match "'cost-center' in object\.metadata\.labels") "cost-center required"
Add-Check "Cost label policy requires environment" ($costPolicy -match "'environment' in object\.metadata\.labels") "environment required"
Add-Check "Cost label policy covers Rollouts" ($costPolicy -match "argoproj\.io") "argoproj.io rollouts"

$costBinding = Read-Text "guardrails\required-cost-labels-binding.yaml"
Add-Check "Cost label binding denies invalid changes" (($costBinding -match "validationActions:") -and ($costBinding -match "- Deny")) "validationActions Deny"
Add-Check "Cost label binding targets guarded namespaces" ($costBinding -match "platform\.aws\.accelerator/guardrails") "guardrails namespace selector"

$lbPolicy = Read-Text "guardrails\deny-loadbalancer-policy.yaml"
Add-Check "LoadBalancer policy fails closed" ($lbPolicy -match "failurePolicy:\s*Fail") "failurePolicy Fail"
Add-Check "LoadBalancer policy requires exception annotation" (($lbPolicy -match "object\.spec\.type != 'LoadBalancer'") -and ($lbPolicy -match "allow-load-balancer")) "exception annotation"

$argocd = Read-Text "integration\w10-day-c-guardrails-app.yaml"
Add-Check "Argo CD app points to current repo" ($argocd -match "https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2.git") "repoURL current repo"
Add-Check "Argo CD app points to Day C guardrails" ($argocd -match "path:\s*cloud/w10/day-c/guardrails") "path cloud/w10/day-c/guardrails"
Add-Check "Argo CD app self-heals" ($argocd -match "selfHeal:\s*true") "selfHeal true"

$incidentRunbook = Read-Text "runbooks\incident-response.md"
Add-Check "Incident runbook covers rollout abort" ($incidentRunbook -match "rollouts abort") "rollouts abort"
Add-Check "Incident runbook covers Git revert" ($incidentRunbook -match "Revert commit") "Git revert"
Add-Check "Incident runbook references W9 SLO alerts" (($incidentRunbook -match "W8ServiceFastBurn") -and ($incidentRunbook -match "W8ServiceSlowBurn")) "W9 SLO alerts"

$costRunbook = Read-Text "runbooks\cost-response.md"
Add-Check "Cost runbook checks quota" ($costRunbook -match "resourcequota w10-cost-guard") "resourcequota check"
Add-Check "Cost runbook checks AWS costs" ($costRunbook -match "aws ce get-cost-and-usage") "Cost Explorer command"
Add-Check "Cost runbook documents LoadBalancer exception expiry" ($costRunbook -match "exception-expiry") "exception expiry"

$protectedWorkloads = @(
    "cloud\w8\day-2\manifests\deployment.yaml",
    "cloud\w8\day-2\manifests\smoke-test-client.yaml",
    "cloud\w9\lab\platform\smoke-test-client.yaml",
    "cloud\w9\day-c\rollout\rollout.yaml",
    "cloud\w9\lab\rollout\rollout.yaml"
)

foreach ($workload in $protectedWorkloads) {
    $workloadText = Read-RepoText $workload
    Add-Check "Protected workload has cost labels: $workload" (Test-CostLabels $workloadText) "owner/cost-center/environment"
}

$kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
if ($kubectl) {
    $renderOutput = & kubectl kustomize (Join-Path $root "guardrails") 2>&1
    Add-Check "kubectl kustomize renders guardrails" ($LASTEXITCODE -eq 0) ($renderOutput -join "`n")
}
else {
    Add-Check "kubectl kustomize renders guardrails" $true "kubectl not found; skipped local render"
}

$failed = $checks | Where-Object { -not $_.Pass }
foreach ($check in $checks) {
    $status = if ($check.Pass) { "PASS" } else { "FAIL" }
    Write-Host ("{0} {1} - {2}" -f $status, $check.Name, $check.Detail)
}

if ($failed) {
    throw "Day C verification failed: $($failed.Count) check(s) failed."
}

Write-Host "Day C artifact verification passed."
