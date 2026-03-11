#!/bin/bash
# Script para desinstalar o Facturio do sistema ou do utilizador atual.

set -euo pipefail

APP_NAME="Facturio"
DESKTOP_FILE="$APP_NAME.desktop"
MODE="system"

usage() {
    echo "Uso: ./uninstall.sh [--system | --user]"
    echo "  --system  Remove a instalação de todos os utilizadores (requer sudo)."
    echo "  --user    Remove apenas a instalação do utilizador atual."
}

case "${1:-}" in
    ""|--system)
        MODE="system"
        ;;
    --user)
        MODE="user"
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        echo "❌ Opção inválida: ${1}"
        usage
        exit 1
        ;;
esac

if [ "$MODE" = "system" ]; then
    INSTALL_DIR="/opt/$APP_NAME"
    APPLICATIONS_DIR="/usr/share/applications"
    ICON_BASE_DIR="/usr/share/icons/hicolor"
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Para desinstalação do sistema use sudo, ou execute: ./uninstall.sh --user"
        exit 1
    fi
else
    INSTALL_DIR="$HOME/.local/opt/$APP_NAME"
    APPLICATIONS_DIR="$HOME/.local/share/applications"
    ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
fi

echo "🗑️  Desinstalando Facturio ($MODE)..."

echo "📦 Removendo arquivos..."
rm -rf "$INSTALL_DIR"

echo "🎨 Removendo ícones..."
rm -f "$ICON_BASE_DIR/48x48/apps/$APP_NAME.png"
rm -f "$ICON_BASE_DIR/128x128/apps/$APP_NAME.png"
rm -f "$ICON_BASE_DIR/256x256/apps/$APP_NAME.png"

echo "📝 Removendo entrada no menu..."
rm -f "$APPLICATIONS_DIR/$DESKTOP_FILE"

echo "♻️  Atualizando cache..."
gtk-update-icon-cache "$ICON_BASE_DIR" -f || true
update-desktop-database "$APPLICATIONS_DIR" || true

echo ""
echo "✅ Facturio desinstalado com sucesso!"
