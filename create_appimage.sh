#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Get the latest dist folder
LATEST_DIST=$(ls -td dist/*/ | head -1)
LINUX_BUILD_DIR="${LATEST_DIST}linux"
APP_DIR="/tmp/Facturio.AppDir"

log() {
  printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$1"
}

log "A preparar estrutura AppImage..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"/{usr/local/bin,usr/local/lib,usr/share/applications,usr/share/icons/hicolor/256x256/apps}

log "A copiar executável..."
cp "$LINUX_BUILD_DIR/Facturio" "$APP_DIR/usr/local/bin/"
chmod +x "$APP_DIR/usr/local/bin/Facturio"

log "A copiar bibliotecas..."
if [ -d "$LINUX_BUILD_DIR/lib" ]; then
  cp -R "$LINUX_BUILD_DIR/lib"/* "$APP_DIR/usr/local/lib/" 2>/dev/null || true
fi

log "A copiar dados..."
if [ -d "$LINUX_BUILD_DIR/data" ]; then
  mkdir -p "$APP_DIR/usr/local/share/facturio"
  cp -R "$LINUX_BUILD_DIR/data"/* "$APP_DIR/usr/local/share/facturio/" 2>/dev/null || true
fi

log "A copiar ícones..."
if [ -f "$LINUX_BUILD_DIR/app_icon.png" ]; then
  cp "$LINUX_BUILD_DIR/app_icon.png" "$APP_DIR/usr/share/icons/hicolor/256x256/apps/Facturio.png"
fi

log "A criar arquivo .desktop..."
cat > "$APP_DIR/usr/share/applications/Facturio.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Facturio
Comment=Facturio empresarial
Exec=/usr/local/bin/Facturio
Icon=Facturio
Terminal=false
Categories=Office;Finance;
Keywords=faturação;faturas;invoice;billing;
StartupWMClass=Facturio
EOF

log "A criar AppRun..."
cat > "$APP_DIR/AppRun" <<'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="${HERE}/usr/local/lib:${LD_LIBRARY_PATH:-}"
export XDG_DATA_DIRS="${HERE}/usr/local/share:${XDG_DATA_DIRS:-}"
exec "${HERE}/usr/local/bin/Facturio" "$@"
EOF
chmod +x "$APP_DIR/AppRun"

log "A tentar usar appimagetool..."
OUTPUT_DIR="$(cd "${LATEST_DIST%/}" && pwd)"
if command -v appimagetool &> /dev/null; then
  appimagetool "$APP_DIR" "${OUTPUT_DIR}/Facturio.AppImage"
  log "AppImage criado com sucesso!"
else
  log "appimagetool não encontrado. A criar tarball alternativo..."
  # Alternativa: criar um tarball que imita a estrutura AppImage
  cd "$APP_DIR"
  tar -czf "${OUTPUT_DIR}/Facturio.AppImage.tar.gz" .
  cd "$PROJECT_DIR" > /dev/null
  log "Arquivo comprimido criado como alternativa: Facturio.AppImage.tar.gz"
fi

rm -rf "$APP_DIR"
log "Processo concluído!"
