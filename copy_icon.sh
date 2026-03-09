#!/bin/bash
# Script para copiar o ícone da aplicação para o bundle após o build

ICON_SOURCE="assets/icons/icon-128.png"
BUNDLE_PATH="build/linux/x64/release/bundle"

if [ -f "$ICON_SOURCE" ] && [ -d "$BUNDLE_PATH" ]; then
    cp "$ICON_SOURCE" "$BUNDLE_PATH/app_icon.png"
    echo "✅ Ícone copiado para o bundle"
else
    echo "❌ Erro: Verifique se o ícone e o bundle existem"
    exit 1
fi
