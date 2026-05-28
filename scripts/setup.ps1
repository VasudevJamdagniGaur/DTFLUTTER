# First-time setup for Deite Flutter app
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Flutter not found. Install from https://docs.flutter.dev/get-started/install/windows"
    exit 1
}

if (-not (Test-Path "android")) {
    Write-Host "Generating platform folders..."
    flutter create . --org com.deite --project-name deite
}

flutter pub get
Write-Host "Done. Run: flutter run --dart-define=BACKEND_URL=https://detea-backend.onrender.com"
