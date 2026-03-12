# Facturio - Pacotes Exportados

## Pacotes Disponíveis

Os pacotes atualmente suportados e exportados em Linux são os seguintes:

### 1. Facturio.apk - Android
- Localização: `dist/20260312_123603/android/Facturio.apk`
- Compatibilidade: Android 5.0+
- Instalação:
  ```bash
  adb install dist/20260312_123603/android/Facturio.apk
  ```

### 2. Facturio.deb - Debian/Ubuntu/Linux
- Localização: `dist/20260312_123603/Facturio.deb`
- Compatibilidade: Debian 10+, Ubuntu 18.04+, Pop!_OS, Linux Mint e compatíveis
- Instalação:
  ```bash
  sudo apt install ./dist/20260312_123603/Facturio.deb
  ```

## Informações da Build

- Versão: 1.0.0
- Data de compilação: 12/03/2026
- Plataforma de build: Linux (Pop!_OS)
- Formatos ativos: APK e DEB

## Dependências por Plataforma

### Android (APK)
- Nenhuma dependência adicional necessária

### Debian/Ubuntu (DEB)
```
Dependência obrigatória:
- libgtk-3-0 (>= 3.0)

Instalação automática: sudo apt install ./dist/20260312_123603/Facturio.deb
```

## Verificação de Integridade

Para verificar os artefactos atuais:

```bash
find dist/20260312_123603 -maxdepth 2 -type f | sort
file dist/20260312_123603/Facturio.deb dist/20260312_123603/android/Facturio.apk
```

## Notas

- O fluxo AppImage foi removido do projeto.
- iOS e macOS estão fora de cogitação no momento.
- O APK pode ser assinado para distribuição na Play Store, se necessário.
- O DEB instala a aplicação no sistema com entrada de menu.

---

Facturio - Sistema de Faturação Empresarial
