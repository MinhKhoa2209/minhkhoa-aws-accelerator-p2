param(
    [Parameter(Mandatory = $true)]
    [string]$Email,
    [string]$Profile = "default",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$LabRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $LabRoot

terraform init
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

terraform apply `
    -auto-approve `
    -var "alert_email=$Email" `
    -var "aws_profile=$Profile" `
    -var "aws_region=$Region"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& (Join-Path $PSScriptRoot "verify.ps1") -Profile $Profile -Region $Region
exit $LASTEXITCODE
