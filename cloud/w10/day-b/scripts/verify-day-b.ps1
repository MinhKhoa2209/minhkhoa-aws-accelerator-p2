$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
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

$requiredFiles = @(
    "README.md",
    "DAY_B_SCRIPT.md",
    "eso\kustomization.yaml",
    "eso\secretstore.yaml",
    "eso\external-secret.yaml",
    "signing\kustomization.yaml",
    "signing\require-signed-images.yaml",
    "ci-trivy\trivy-cosign.yml",
    "ci-trivy\cve-exception-template.md"
)

foreach ($file in $requiredFiles) {
    $path = Join-Path $root $file
    Add-Check "Required file: $file" (Test-Path -LiteralPath $path) $path
}

$externalSecret = Read-Text "eso\external-secret.yaml"
$refreshMatch = [regex]::Match($externalSecret, "refreshInterval:\s*(\d+)s")
if ($refreshMatch.Success) {
    $seconds = [int]$refreshMatch.Groups[1].Value
    Add-Check "ESO refreshInterval <= 60s" ($seconds -le 60) "refreshInterval=${seconds}s"
}
else {
    Add-Check "ESO refreshInterval <= 60s" $false "refreshInterval not found"
}

$secretStore = Read-Text "eso\secretstore.yaml"
Add-Check "ESO uses AWS Secrets Manager" ($secretStore -match "service:\s*SecretsManager") "provider aws SecretsManager"
Add-Check "ESO region is us-east-1" ($secretStore -match "region:\s*us-east-1") "region us-east-1"

$kyverno = Read-Text "signing\require-signed-images.yaml"
Add-Check "Kyverno policy enforces failures" ($kyverno -match "validationFailureAction:\s*Enforce") "validationFailureAction Enforce"
Add-Check "Kyverno verifyImages enforces failures" ($kyverno -match "failureAction:\s*Enforce") "failureAction Enforce"
Add-Check "Kyverno webhook fails closed" (($kyverno -match "webhookConfiguration:") -and ($kyverno -match "failurePolicy:\s*Fail")) "webhookConfiguration failurePolicy Fail"
Add-Check "Kyverno verifies images" ($kyverno -match "verifyImages:") "verifyImages present"
Add-Check "Kyverno checks GitHub OIDC issuer" ($kyverno -match "https://token.actions.githubusercontent.com") "GitHub OIDC issuer"
Add-Check "Kyverno checks Sigstore Rekor" ($kyverno -match "https://rekor.sigstore.dev") "Rekor transparency log"
Add-Check "Kyverno scopes GHCR image references" ($kyverno -match "ghcr.io/minhkhoa2209/\*") "ghcr.io/minhkhoa2209/*"

$workflow = Read-Text "ci-trivy\trivy-cosign.yml"
Add-Check "Trivy fails HIGH/CRITICAL" (($workflow -match "severity:\s*HIGH,CRITICAL") -and ($workflow -match 'exit-code:\s*"1"')) "severity HIGH,CRITICAL and exit-code 1"
Add-Check "Workflow has Cosign signing" ($workflow -match "cosign sign --yes") "cosign sign --yes"
Add-Check "Workflow has OIDC permission" ($workflow -match "id-token:\s*write") "id-token write"

$failed = $checks | Where-Object { -not $_.Pass }
foreach ($check in $checks) {
    $status = if ($check.Pass) { "PASS" } else { "FAIL" }
    Write-Host ("{0} {1} - {2}" -f $status, $check.Name, $check.Detail)
}

if ($failed) {
    throw "Day B verification failed: $($failed.Count) check(s) failed."
}

Write-Host "Day B artifact verification passed."
