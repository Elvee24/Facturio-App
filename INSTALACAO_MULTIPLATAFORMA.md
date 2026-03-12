# Facturio - Instalação e Build Multi-Plataforma

Este guia complementa o `INSTALACAO_LINUX.md` e descreve o fluxo atualmente suportado para gerar artefatos do Facturio.

## Matriz de Suporte por Host

- **Host Linux**: build `linux`, `apk`, `appbundle`, `web`
- **Host Windows**: build `windows`, `apk`, `appbundle`, `web`

Notas importantes:
- `flutter build windows` exige host Windows.
- iOS e macOS estão fora de cogitação no momento e não fazem parte do fluxo atual de entrega.

## 1) Preparar Dependencias

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

Android (opcional, para APK/AAB):

- Instalar Android Studio
- Instalar Android SDK Command-line Tools
- Aceitar licencas:

```bash
flutter doctor --android-licenses
```

### Windows

PowerShell (admin), com Chocolatey:

```powershell
choco install -y git 7zip
choco install -y visualstudio2022community visualstudio2022-workload-nativedesktop
```

Android (opcional):

- Instalar Android Studio + SDK
- Aceitar licencas:

```powershell
flutter doctor --android-licenses
```

## 2) Preparar Projeto

Em qualquer host:

```bash
cd /caminho/para/Facturio
flutter clean
flutter pub get
flutter doctor -v
```

## 3) Builds por Plataforma

### Linux

```bash
flutter build linux --release
```

Artefato:
- `build/linux/x64/release/bundle/Facturio`

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

Artefatos:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### Web

```bash
flutter build web --release
```

Artefato:
- `build/web/`

### Windows (apenas em host Windows)

```powershell
flutter config --enable-windows-desktop
flutter build windows --release
```

Artefato:
- `build\windows\x64\runner\Release\`

## 4) Validacao Rapida

```bash
flutter analyze
flutter test test/backup_service_e2e_test.dart
```

## 5) Exportacao Automatizada

No Linux, podes usar o script existente:

```bash
./export_packages.sh
```

Ou via VS Code task:

- `Terminal -> Run Task -> Facturio: Exportar pacotes`

## 6) Problemas Comuns

- **"Build windows is only supported on Windows hosts"**: executar em maquina Windows.
- **Licencas Android pendentes**: correr `flutter doctor --android-licenses`.
- **Falta toolchain desktop**: confirmar `flutter doctor -v` e instalar dependencias do host.
- **Build iOS/macOS pedida**: fora de cogitação no momento neste projeto.

## 7) Scripts Prontos por Host

Foram adicionados scripts de automacao no root do projeto:

- Linux: `./build_linux.sh`
- Windows (PowerShell): `./build_windows.ps1`

O que fazem:

- `flutter doctor -v`
- `flutter pub get`
- `flutter analyze`
- `flutter test test/backup_service_e2e_test.dart`
- builds release do host e tambem Android/Web

## 8) Checklist Rapida por Host

### Linux

- Toolchain Linux instalada (`clang`, `cmake`, `ninja`, `libgtk-3-dev`)
- Android SDK configurado (se precisares APK/AAB)
- Comando: `./build_linux.sh`

### Windows

- Visual Studio com workload "Desktop development with C++"
- Android SDK configurado (se precisares APK/AAB)
- Comando: `powershell -ExecutionPolicy Bypass -File .\build_windows.ps1`

### Estado Atual

- Linux, Android e Web fazem parte do fluxo ativo.
- Windows mantém suporte de build apenas em host Windows.
- iOS e macOS estão fora de cogitação no momento.
