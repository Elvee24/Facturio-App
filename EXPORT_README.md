# Facturio - Pacotes Exportados

## 📦 Pacotes Disponíveis

Os seguintes pacotes foram exportados com sucesso em **11 de Março de 2026**:

### 1. **Facturio.apk** (56 MB) - Android
- **Localização**: `Facturio.apk` ou `dist/20260311_213848/android/Facturio.apk`
- **Compatibilidade**: Android 5.0+
- **Instalação**: 
  ```bash
  # Via ADB (Android Debug Bridge)
  adb install Facturio.apk
  
  # Ou transferir para dispositivo Android e instalar via gestor de ficheiros
  ```

### 2. **Facturio.deb** (19 MB) - Debian/Ubuntu/Linux
- **Localização**: `Facturio.deb` ou `dist/20260311_213848/Facturio.deb`
- **Compatibilidade**: Debian 10+, Ubuntu 18.04+, Pop!_OS, Linux Mint, etc.
- **Instalação**:
  ```bash
  # Via apt
  sudo apt install ./Facturio.deb
  
  # Ou via dpkg
  sudo dpkg -i Facturio.deb
  sudo apt install -f  # Se houver dependências faltando
  ```

### 3. **Facturio.AppImage.tar.gz** (23 MB) - Linux AppImage
- **Localização**: `Facturio.AppImage.tar.gz` ou `dist/20260311_213848/Facturio.AppImage.tar.gz`
- **Compatibilidade**: Linux geral (sem dependências do sistema)
- **Instalação**:
  ```bash
  # 1. Extrair o arquivo
  tar -xzf Facturio.AppImage.tar.gz -C ~/.local/share/applications/
  
  # 2. Tornar executável
  chmod +x AppDir/AppRun
  
  # 3. Executar
  ./AppDir/AppRun
  ```

## 📋 Informações da Build

- **Versão**: 1.0.0
- **Data de Compilação**: 11/03/2026 às 21:43 (UTC)
- **Plataforma de Build**: Linux (Pop!_OS)
- **Tamanho Total**: ~98 MB (3 formatos)

## 🔧 Dependências por Plataforma

### Android (APK)
- Nenhuma dependência adicional necessária

### Debian/Ubuntu (DEB)
```
Dependência obrigatória:
- libgtk-3-0 (>= 3.0)

Instalação automática: sudo apt install ./Facturio.deb
```

### Linux (AppImage)
```
Dependências de tempo de execução:
- libgtk-3-0 (>= 3.0)
- Bibliotecas gráficas padrão do Linux

Incluído no arquivo:
- Todas as bibliotecas Flutter necessárias
- Recursos de dados da aplicação
```

## ✅ Verificação de Integridade

Para verificar a integridade dos arquivos:

```bash
# Listar arquivos
ls -lh Facturio.*

# Verificar tipo de arquivo
file Facturio.*

# Tamanho esperado
- Facturio.apk: ~56 MB
- Facturio.deb: ~19 MB
- Facturio.AppImage.tar.gz: ~23 MB
```

## 🚀 Próximos Passos

1. **Testar em cada plataforma** para garantir funcionamento
2. **Reportar erros** se encontrados durante testes
3. **Fazer backup** dos pacotes em local seguro
4. **Distribuir** aos utilizadores finais conforme apropriado

## 📝 Notas Adicionais

- Os pacotes foram gerados automaticamente usando Flutter build
- A aplicação é totalmente portável (sem instalação requerida para AppImage)
- O APK pode ser assinado para distribuição em Play Store se necessário
- O DEB permite instalação do sistema com entrada de menu

---

**Facturio** - Sistema de Faturação Empresarial Multiplataforma
