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

$secrets = "lib/config/firebase_secrets.dart"
$example = "lib/config/firebase_secrets.example.dart"
if (-not (Test-Path $secrets) -and (Test-Path $example)) {
    Copy-Item $example $secrets
    Write-Host "Created $secrets — add your Firebase API key from Firebase Console."
}

flutter pub get
Write-Host "Done. Run: flutter run --dart-define=BACKEND_URL=https://detea-backend.onrender.com"
