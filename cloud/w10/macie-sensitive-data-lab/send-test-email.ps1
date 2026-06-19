# Script to send test event to trigger email alert
# Use this if you confirmed SNS subscription but haven't received email yet

$region = "us-east-1"
$eventFile = "test-event.json"

Write-Host "Sending test Macie finding event..." -ForegroundColor Cyan

$result = aws events put-events `
    --entries "file://$eventFile" `
    --region $region | ConvertFrom-Json

if ($result.FailedEntryCount -eq 0) {
    Write-Host "✅ Test event sent successfully!" -ForegroundColor Green
    Write-Host "Check your email: dinhminhkhoa.dev@gmail.com" -ForegroundColor Yellow
    Write-Host "Email subject will contain: 'Macie Finding'" -ForegroundColor Yellow
} else {
    Write-Host "❌ Failed to send test event" -ForegroundColor Red
    Write-Host $result | ConvertTo-Json -Depth 5
}
