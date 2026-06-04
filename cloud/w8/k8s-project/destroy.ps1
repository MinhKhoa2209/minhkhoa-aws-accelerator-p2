$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

& terraform init
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& terraform destroy -auto-approve
exit $LASTEXITCODE
