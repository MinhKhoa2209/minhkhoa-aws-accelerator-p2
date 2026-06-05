$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $ProjectRoot

& terraform init
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& terraform destroy -auto-approve
exit $LASTEXITCODE
