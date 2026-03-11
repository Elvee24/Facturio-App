#!/bin/bash

# Script para instalar o ícone do Facturio no sistema Linux

echo "🎨 Instalando ícone do Facturio..."

# Diretórios
BUNDLE_DIR="build/linux/x64/debug/bundle"
ICON_DIR="$HOME/.local/share/icons/hicolor"
DESKTOP_DIR="$HOME/.local/share/applications"

# Criar diretórios se não existirem
mkdir -p "$ICON_DIR/16x16/apps"
mkdir -p "$ICON_DIR/32x32/apps"
mkdir -p "$ICON_DIR/48x48/apps"
mkdir -p "$ICON_DIR/64x64/apps"
mkdir -p "$ICON_DIR/128x128/apps"
mkdir -p "$ICON_DIR/256x256/apps"
mkdir -p "$ICON_DIR/512x512/apps"
mkdir -p "$ICON_DIR/scalable/apps"
mkdir -p "$DESKTOP_DIR"

# Copiar ícones
echo "📋 Copiando ícones..."
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-16.png" "$ICON_DIR/16x16/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-32.png" "$ICON_DIR/32x32/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-48.png" "$ICON_DIR/48x48/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-64.png" "$ICON_DIR/64x64/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-128.png" "$ICON_DIR/128x128/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-256.png" "$ICON_DIR/256x256/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/icon-512.png" "$ICON_DIR/512x512/apps/Facturio.png"
cp "$BUNDLE_DIR/data/flutter_assets/assets/icons/app_icon.svg" "$ICON_DIR/scalable/apps/Facturio.svg"

# Copiar .desktop
echo "📝 Instalando atalho na aplicação..."
cp linux/Facturio.desktop "$DESKTOP_DIR/Facturio.desktop"

# Atualizar .desktop com caminho correto do executável
sed -i "s|Exec=Facturio|Exec=$PWD/$BUNDLE_DIR/Facturio|" "$DESKTOP_DIR/Facturio.desktop"
sed -i "s|Icon=Facturio|Icon=$ICON_DIR/scalable/apps/Facturio.svg|" "$DESKTOP_DIR/Facturio.desktop"

# Atualizar cache de ícones
echo "🔄 Atualizando cache de ícones..."
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR"
fi

if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi

echo ""
echo "✅ Instalação concluída!"
echo ""
echo "📍 Ícones instalados em: $ICON_DIR"
echo "📍 Atalho instalado em: $DESKTOP_DIR/Facturio.desktop"
echo ""
echo "💡 Dica: Pode ser necessário reiniciar o ambiente gráfico ou fazer logout/login"
echo "         para que o ícone apareça no menu de aplicações."
echo ""
echo "🔍 Para testar, procure por 'Facturio' no menu de aplicações do sistema."
