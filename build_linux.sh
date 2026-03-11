#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

log() {
  printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$1"
}

log "A validar ambiente Flutter..."
flutter doctor -v

log "A instalar dependencias do projeto..."
flutter pub get

log "A correr validacoes rapidas..."
flutter analyze
flutter test test/backup_service_e2e_test.dart

log "A gerar build Linux release..."
flutter build linux --release

log "A gerar build Android APK/AAB release..."
flutter build apk --release
flutter build appbundle --release

log "A gerar build Web release..."
flutter build web --release

log "Builds concluidos. Artefatos principais:"
echo "- Linux: build/linux/x64/release/bundle/Facturio"
echo "- Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "- Android AAB: build/app/outputs/bundle/release/app-release.aab"
echo "- Web: build/web/"
