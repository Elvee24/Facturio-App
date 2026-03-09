# Facturio - Instalação Linux

## Instalação no Sistema

Para instalar o Facturio no seu sistema Linux e adicionar ao menu de aplicações:

```bash
sudo ./install.sh
```

Após a instalação:
- A aplicação estará disponível no menu de aplicações
- Procure por "Facturio" no launcher
- Ícone profissional será exibido

## Desinstalação

Para remover a aplicação do sistema:

```bash
sudo ./uninstall.sh
```

## Executar sem Instalar

Para executar diretamente sem instalar no sistema:

```bash
./build/linux/x64/release/bundle/Facturio
```

## Build

Para recompilar a aplicação:

```bash
flutter build linux --release
```

## Estrutura de Instalação

- **Executável:** `/opt/Facturio/`
- **Ícones:** `/usr/share/icons/hicolor/{48x48,128x128,256x256}/apps/`
- **Desktop Entry:** `/usr/share/applications/Facturio.desktop`

## Ícones Incluídos

O package inclui automaticamente:
- ✅ Ícone da aplicação (app_icon.png) no bundle
- ✅ Arquivo .desktop para o menu do sistema
- ✅ Múltiplos tamanhos de ícones (48px, 128px, 256px)
- ✅ Logo SVG integrado na aplicação

## Requisitos

- Ubuntu 20.04+ / Pop!_OS / Debian-based
- GTK 3.0
- Bibliotecas C++ instaladas
