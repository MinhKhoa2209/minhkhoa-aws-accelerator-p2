$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Invoke-Terraform {
  param(
    [Parameter(Mandatory = $true)]
    [string[]] $Command
  )

  & terraform @Command
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

Invoke-Terraform -Command @("init")
Invoke-Terraform -Command @("apply", "-auto-approve")

$albUrl = (& terraform output -raw alb_url).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($albUrl)) {
  exit 1
}

$healthUrl = "$albUrl/healthz"
Write-Host "ALB URL: $albUrl"
Write-Host "Waiting for $healthUrl ..."

for ($attempt = 1; $attempt -le 60; $attempt++) {
  try {
    $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
      Write-Host "Application is healthy."
      Write-Host $albUrl
      exit 0
    }
  }
  catch {
    Write-Host "Attempt $attempt/60: not ready yet."
  }

  Start-Sleep -Seconds 15
}

Write-Error "Application did not become healthy through the ALB in time."
exit 1
