#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Get the latest dist folder
LATEST_DIST=$(ls -td dist/*/ | head -1)
LINUX_BUILD_DIR="${LATEST_DIST}linux"
DEB_DIR="/tmp/facturio-deb"
VERSION="1.0.0"

log() {
  printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$1"
}

log "A preparar estrutura Debian..."
rm -rf "$DEB_DIR"
# Use /opt/facturio for the application (preserves relative paths)
mkdir -p "$DEB_DIR"/{opt/facturio,usr/local/bin,usr/share/applications,usr/share/icons/hicolor/256x256/apps,usr/share/doc/facturio,DEBIAN}

log "A copiar executável..."
cp "$LINUX_BUILD_DIR/Facturio" "$DEB_DIR/opt/facturio/"
chmod +x "$DEB_DIR/opt/facturio/Facturio"

log "A copiar bibliotecas..."
if [ -d "$LINUX_BUILD_DIR/lib" ]; then
  mkdir -p "$DEB_DIR/opt/facturio/lib"
  cp -R "$LINUX_BUILD_DIR/lib"/* "$DEB_DIR/opt/facturio/lib/" 2>/dev/null || true
  chmod -R u+w "$DEB_DIR/opt/facturio/lib/" 2>/dev/null || true
fi

log "A copiar dados..."
if [ -d "$LINUX_BUILD_DIR/data" ]; then
  mkdir -p "$DEB_DIR/opt/facturio/data"
  cp -R "$LINUX_BUILD_DIR/data"/* "$DEB_DIR/opt/facturio/data/" 2>/dev/null || true
  # Ensure proper permissions
  find "$DEB_DIR/opt/facturio/data/" -type f -exec chmod 644 {} \; 2>/dev/null || true
  find "$DEB_DIR/opt/facturio/data/" -type d -exec chmod 755 {} \; 2>/dev/null || true
fi

log "A copiar ícones..."
if [ -f "$LINUX_BUILD_DIR/app_icon.png" ]; then
  cp "$LINUX_BUILD_DIR/app_icon.png" "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/Facturio.png"
fi

log "A criar script wrapper..."
cat > "$DEB_DIR/usr/local/bin/Facturio" <<'WRAPPER_EOF'
#!/bin/bash
# Wrapper script for Facturio Flutter application
# Execute from /opt/facturio to preserve relative paths for lib/ and data/
cd /opt/facturio
export LD_LIBRARY_PATH="/opt/facturio/lib:${LD_LIBRARY_PATH:-}"
export XDG_DATA_DIRS="/usr/share:${XDG_DATA_DIRS:-}"
exec ./Facturio "$@"
WRAPPER_EOF
chmod +x "$DEB_DIR/usr/local/bin/Facturio"

log "A copiar ficheiro .desktop..."
if [ -f "$PROJECT_DIR/linux/Facturio.desktop" ]; then
  cp "$PROJECT_DIR/linux/Facturio.desktop" "$DEB_DIR/usr/share/applications/"
else
  # Create a default one if not found
  cat > "$DEB_DIR/usr/share/applications/Facturio.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Facturio
Comment=Facturio empresarial
Exec=Facturio
Icon=Facturio
Terminal=false
Categories=Office;Finance;
Keywords=faturação;faturas;invoice;billing;
StartupWMClass=Facturio
EOF
fi

log "A criar arquivo control..."
cat > "$DEB_DIR/DEBIAN/control" <<EOF
Package: facturio
Version: ${VERSION}
Architecture: amd64
Maintainer: IEFP <dev@iefp.pt>
Description: Facturio empresarial
 Sistema de faturação empresarial multiplataforma para gestão de faturas,
 recibos e pagamentos com suporte a múltiplas moedas e integração com
 sistemas de pagamento.
Homepage: https://github.com/JosuSM/Facturio
Depends: libgtk-3-0 (>= 3.0)
EOF

log "A criar script pré-instalação..."
cat > "$DEB_DIR/DEBIAN/preinst" <<'EOF'
#!/bin/bash
set -e
exit 0
EOF
chmod +x "$DEB_DIR/DEBIAN/preinst"

log "A criar script pré-remoção..."
cat > "$DEB_DIR/DEBIAN/prerm" <<'EOF'
#!/bin/bash
set -e

if [ "$1" = "remove" ] || [ "$1" = "upgrade" ]; then
  # Remove cache/temp files if any
  rm -rf /opt/facturio/.flutter_cache 2>/dev/null || true
  rm -rf /opt/facturio/.dart_cache 2>/dev/null || true
fi

exit 0
EOF
chmod +x "$DEB_DIR/DEBIAN/prerm"

log "A criar script pós-instalação..."
cat > "$DEB_DIR/DEBIAN/postinst" <<'EOF'
#!/bin/bash
set -e

if [ "$1" = "configure" ]; then
  # Ensure /opt/facturio is owned by the app
  if [ ! -d /opt/facturio ]; then
    mkdir -p /opt/facturio
  fi
  
  # Update desktop database and icon cache
  update-desktop-database /usr/share/applications 2>/dev/null || true
  gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
fi

exit 0
EOF
chmod +x "$DEB_DIR/DEBIAN/postinst"

log "A criar copyright..."
cat > "$DEB_DIR/usr/share/doc/facturio/copyright" <<'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/

Files: *
Copyright: 2024 IEFP
License: MIT
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 .
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
EOF

log "A criar changelog..."
cat > "$DEB_DIR/usr/share/doc/facturio/changelog" <<'EOF'
facturio (1.0.0) unstable; urgency=medium

  * Initial release

 -- IEFP <dev@iefp.pt>  $(date -R)
EOF

log "A construir pacote Debian..."
OUTPUT_DIR="$(cd "${LATEST_DIST%/}" && pwd)"
fakeroot dpkg-deb --build "$DEB_DIR" "${OUTPUT_DIR}/Facturio.deb"

log "Limpando arquivos temporários..."
rm -rf "$DEB_DIR"

log "Pacote Debian criado com sucesso!"
ls -lh "${OUTPUT_DIR}/Facturio.deb"
