$env:PATH = "$HOME\Downloads\flutter\bin;$env:PATH"
Set-Location -Path $PSScriptRoot
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting VetCare Flutter App on http://localhost:3000 ..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
flutter run -d chrome --web-port=3000
