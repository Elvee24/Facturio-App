#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Este script so pode ser executado em macOS."
  exit 1
fi

log() {
  printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$1"
}

log "A ativar plataformas desktop Apple..."
flutter config --enable-macos-desktop

log "A validar ambiente Flutter/Xcode..."
flutter doctor -v

log "A instalar dependencias do projeto..."
flutter pub get

log "A correr validacoes rapidas..."
flutter analyze
flutter test test/backup_service_e2e_test.dart

log "A gerar build macOS release..."
flutter build macos --release

log "A gerar build iOS release..."
flutter build ios --release

log "A gerar build Android APK/AAB release..."
flutter build apk --release
flutter build appbundle --release

log "A gerar build Web release..."
flutter build web --release

log "Builds concluidos. Artefatos principais:"
echo "- macOS: build/macos/Build/Products/Release/"
echo "- iOS app: build/ios/iphoneos/Runner.app"
echo "- Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "- Android AAB: build/app/outputs/bundle/release/app-release.aab"
echo "- Web: build/web/"
