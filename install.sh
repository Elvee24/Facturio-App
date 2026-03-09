#!/bin/bash
# Script para instalar o Facturio no sistema

set -e

APP_NAME="Facturio"
INSTALL_DIR="/opt/$APP_NAME"
DESKTOP_FILE="$APP_NAME.desktop"

echo "🚀 Instalando Facturio..."

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Por favor, execute como root (sudo)"
    exit 1
fi

# Criar diretório de instalação
echo "📁 Criando diretório de instalação..."
mkdir -p "$INSTALL_DIR"

# Copiar arquivos da aplicação
echo "📦 Copiando arquivos..."
cp -r build/linux/x64/release/bundle/* "$INSTALL_DIR/"

# Tornar o executável executável
chmod +x "$INSTALL_DIR/$APP_NAME"

# Instalar ícones
echo "🎨 Instalando ícones..."
mkdir -p /usr/share/icons/hicolor/48x48/apps
mkdir -p /usr/share/icons/hicolor/128x128/apps
mkdir -p /usr/share/icons/hicolor/256x256/apps

cp assets/icons/icon-48.png /usr/share/icons/hicolor/48x48/apps/$APP_NAME.png
cp assets/icons/icon-128.png /usr/share/icons/hicolor/128x128/apps/$APP_NAME.png
cp assets/icons/icon-256.png /usr/share/icons/hicolor/256x256/apps/$APP_NAME.png

# Criar arquivo desktop
echo "📝 Criando entrada no menu..."
cat > /usr/share/applications/$DESKTOP_FILE << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Facturio
Comment=Facturio empresarial
Exec=$INSTALL_DIR/$APP_NAME
Icon=$APP_NAME
Terminal=false
Categories=Office;Finance;
Keywords=faturação;faturas;invoice;billing;
StartupWMClass=$APP_NAME
EOF

# Atualizar cache de ícones
echo "♻️  Atualizando cache..."
gtk-update-icon-cache /usr/share/icons/hicolor/ -f || true
update-desktop-database /usr/share/applications/ || true

echo ""
echo "✅ Instalação concluída!"
echo "📱 Você pode encontrar o Facturio no menu de aplicações."
echo ""
echo "Para desinstalar, execute: sudo rm -rf $INSTALL_DIR /usr/share/applications/$DESKTOP_FILE"
