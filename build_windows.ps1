$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

function Log-Step {
    param([string]$Message)
    $ts = Get-Date -Format "HH:mm:ss"
    Write-Host "`n[$ts] $Message"
}

if (-not $IsWindows) {
    Write-Error "Este script so pode ser executado em Windows."
}

Log-Step "A ativar plataforma Windows desktop..."
flutter config --enable-windows-desktop

Log-Step "A validar ambiente Flutter..."
flutter doctor -v

Log-Step "A instalar dependencias do projeto..."
flutter pub get

Log-Step "A correr validacoes rapidas..."
flutter analyze
flutter test test/backup_service_e2e_test.dart

Log-Step "A gerar build Windows release..."
flutter build windows --release

Log-Step "A gerar build Android APK/AAB release..."
flutter build apk --release
flutter build appbundle --release

Log-Step "A gerar build Web release..."
flutter build web --release

Log-Step "Builds concluidos. Artefatos principais:"
Write-Host "- Windows: build\windows\x64\runner\Release\"
Write-Host "- Android APK: build\app\outputs\flutter-apk\app-release.apk"
Write-Host "- Android AAB: build\app\outputs\bundle\release\app-release.aab"
Write-Host "- Web: build\web\"
