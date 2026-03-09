#!/bin/bash
# Script para desinstalar o Facturio

set -e

APP_NAME="Facturio"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="$APP_NAME.desktop"

echo "🗑️  Desinstalando Facturio..."

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Por favor, execute como root (sudo)"
    exit 1
fi

# Remover arquivos
echo "📦 Removendo arquivos..."
rm -rf "$INSTALL_DIR"

# Remover ícones
echo "🎨 Removendo ícones..."
rm -f /usr/share/icons/hicolor/48x48/apps/$APP_NAME.png
rm -f /usr/share/icons/hicolor/128x128/apps/$APP_NAME.png
rm -f /usr/share/icons/hicolor/256x256/apps/$APP_NAME.png

# Remover arquivo desktop
echo "📝 Removendo entrada no menu..."
rm -f /usr/share/applications/$DESKTOP_FILE

# Atualizar cache
echo "♻️  Atualizando cache..."
gtk-update-icon-cache /usr/share/icons/hicolor/ -f || true
update-desktop-database /usr/share/applications/ || true

echo ""
echo "✅ Facturio desinstalado com sucesso!"
