#!/bin/bash
# Script para instalar o Facturio no sistema ou apenas para o utilizador atual.

set -euo pipefail

APP_NAME="Facturio"
DESKTOP_FILE="$APP_NAME.desktop"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="system"

usage() {
    echo "Uso: ./install.sh [--system | --user]"
    echo "  --system  Instala para todos os utilizadores (requer sudo)."
    echo "  --user    Instala apenas para o utilizador atual."
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
        echo "❌ Para instalação no sistema use sudo, ou execute: ./install.sh --user"
        exit 1
    fi
else
    INSTALL_DIR="$HOME/.local/opt/$APP_NAME"
    APPLICATIONS_DIR="$HOME/.local/share/applications"
    ICON_BASE_DIR="$HOME/.local/share/icons/hicolor"
fi

BUNDLE_DIR="$SCRIPT_DIR/build/linux/x64/release/bundle"
EXECUTABLE_PATH="$INSTALL_DIR/$APP_NAME"
DESKTOP_PATH="$APPLICATIONS_DIR/$DESKTOP_FILE"
ICON_48_DIR="$ICON_BASE_DIR/48x48/apps"
ICON_128_DIR="$ICON_BASE_DIR/128x128/apps"
ICON_256_DIR="$ICON_BASE_DIR/256x256/apps"
ICON_SCALABLE_DIR="$ICON_BASE_DIR/scalable/apps"

echo "🚀 Instalando Facturio ($MODE)..."

if [ ! -x "$BUNDLE_DIR/$APP_NAME" ]; then
    echo "🔨 Build release não encontrado. A compilar..."
    (
        cd "$SCRIPT_DIR"
        flutter build linux --release
    )
fi

echo "📁 Criando diretórios de instalação..."
mkdir -p "$INSTALL_DIR" "$APPLICATIONS_DIR" "$ICON_48_DIR" "$ICON_128_DIR" "$ICON_256_DIR" "$ICON_SCALABLE_DIR"

echo "📦 Copiando arquivos da aplicação..."
cp -r "$BUNDLE_DIR"/. "$INSTALL_DIR/"
chmod +x "$EXECUTABLE_PATH"

echo "🎨 Instalando ícones..."
install -m 644 "$SCRIPT_DIR/assets/icons/icon-48.png" "$ICON_48_DIR/$APP_NAME.png"
install -m 644 "$SCRIPT_DIR/assets/icons/icon-128.png" "$ICON_128_DIR/$APP_NAME.png"
install -m 644 "$SCRIPT_DIR/assets/icons/icon-256.png" "$ICON_256_DIR/$APP_NAME.png"
install -m 644 "$SCRIPT_DIR/assets/icons/app_icon.svg" "$ICON_SCALABLE_DIR/$APP_NAME.svg"

echo "📝 Criando entrada no menu..."
cat > "$DESKTOP_PATH" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Facturio
Comment=Facturio empresarial
Exec=$EXECUTABLE_PATH
Icon=$ICON_SCALABLE_DIR/$APP_NAME.svg
Terminal=false
Categories=Office;Finance;
Keywords=faturacao;faturas;invoice;billing;
StartupWMClass=$APP_NAME
EOF
chmod 644 "$DESKTOP_PATH"

echo "♻️  Atualizando cache..."
gtk-update-icon-cache "$ICON_BASE_DIR" -f || true
update-desktop-database "$APPLICATIONS_DIR" || true

echo ""
echo "✅ Instalação concluída!"
echo "📱 Procure por Facturio no menu de aplicações."
echo "📂 Executável: $EXECUTABLE_PATH"
echo "📝 Launcher: $DESKTOP_PATH"
if [ "$MODE" = "system" ]; then
    echo "🗑️  Para desinstalar: sudo ./uninstall.sh"
else
    echo "🗑️  Para desinstalar: ./uninstall.sh --user"
fi
