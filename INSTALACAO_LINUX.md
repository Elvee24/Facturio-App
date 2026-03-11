# Facturio - Instalação Linux

> Para builds em Windows, macOS e iOS, consulte tambem: `INSTALACAO_MULTIPLATAFORMA.md`

## Instalação no Sistema

Para instalar o Facturio no seu sistema Linux e adicionar ao menu de aplicações:

```bash
sudo ./install.sh --system
```

Também é aceite sem flag:

```bash
sudo ./install.sh
```

## Instalação Apenas para o Utilizador Atual

Para instalar sem sudo, apenas para a sua conta:

```bash
./install.sh --user
```

Após a instalação:
- A aplicação estará disponível no menu de aplicações
- Procure por "Facturio" no launcher
- Ícone profissional será exibido

## Desinstalação

Para remover a aplicação do sistema:

```bash
sudo ./uninstall.sh --system
```

Para remover apenas a instalação do utilizador atual:

```bash
./uninstall.sh --user
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

## Primeiros Passos na Aplicação

### PIN do Administrador
- **PIN Padrão:** 1234
- Necessário para aceder às Configurações da Empresa

### Criar Backup dos Dados
1. Abra a aplicação
2. Clique em **Criar Backup** no menu
3. Seleccione o local para guardar o ficheiro JSON
4. Ficheiro será nomeado: `backup_YYYY-MM-DD_HH-MM-SS.json`

### Restaurar a partir de Backup
1. Clique em **Restaurar Backup** no menu
2. Seleccione um ficheiro de backup anteriormente guardado
3. Confirme a restauração
4. Todos os dados (clientes, produtos, faturas, configurações) serão restaurados

### Configurações da Empresa
1. Clique em **Configurações da Empresa** no Dashboard
2. Introduza o PIN (padrão: 1234)
3. Customize:
   - **Taxas de IVA** (adicione/remova)
   - **Unidades de Medida** (adicione/remova)
   - **Estados de Fatura** (adicione/remova)
   - **Alterar PIN** (mude a senha do administrador)
4. As alterações são guardadas automaticamente

## Estrutura de Instalação

- **Executável:** `/opt/Facturio/`
- **Ícones:** `/usr/share/icons/hicolor/{48x48,128x128,256x256}/apps/`
- **Desktop Entry:** `/usr/share/applications/Facturio.desktop`
- **Dados**: Guardados localmente em base de dados Hive (não requerem permissões root)

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

## Segurança dos Dados

- Todos os dados são guardados localmente no seu computador
- Não existem servidores remotos
- Faça backups regulares para proteger os seus dados
- O PIN é encriptado com SHA-256

## Exportar Pacotes Multi-Plataforma

Para gerar pacotes de instalação para todas as plataformas:

### Via Script Bash
```bash
./export_packages.sh
```

### Via VS Code Task
```
Terminal → Run Task → Facturio: Exportar pacotes
```

Resultado: Pasta `dist/YYYYMMDD_HHMMSS/` com:
- **Android:** app-release.apk e app-release.aab
- **Web:** Build web (distribuível em servidores)
- **Linux:** Binary e assets para distribuição
- **iOS/macOS/Windows:** Ficheiros de configuração (requer respectivos ambientes)
