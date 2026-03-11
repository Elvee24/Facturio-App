# Facturio

Aplicação de faturação empresarial, desenvolvida em Flutter, com foco em produtividade, personalização por empresa e distribuição multi-plataforma.

## 📋 Índice

- [Pontos fortes da aplicação](#pontos-fortes-da-aplicação)
- [Principais novidades](#principais-novidades)
- [Requisitos](#requisitos)
- [Instalação](#instalação-correta-passo-a-passo)
- [Checklist de Commit Seguro](#checklist-de-commit-seguro)
- [Tutorial Interativo](#tutorial-interativo)
- [Sistema de Personalização](#sistema-de-personalização)
- [Sistema de Pagamentos](#sistema-de-pagamentos)
- [Acesso de administrador (PIN)](#acesso-de-administrador-pin)
- [Exportar pacotes](#exportar-pacotes-de-instalação)
- [Estrutura do projeto](#estrutura-relevante-do-projeto)
- [Qualidade de código](#qualidade-de-código)
- [Notas importantes](#notas-importantes)

## Pontos fortes da aplicação

- Gestão completa de clientes, produtos e faturas (CRUD).
- **Sistema de gestão de pagamentos:**
  - Suporte para múltiplos pagamentos parciais por fatura.
  - 10 meios de pagamento pré-configurados (Numerário, Transferência, MB Way, etc.).
  - Cálculo automático de valores pagos, em dívida e percentagem paga.
  - Histórico completo de pagamentos com data, valor, meio e referência.
  - Status visual com barra de progresso e cores (verde=pago, laranja=parcial, vermelho=não pago).
  - Validações automáticas (não permite pagamento superior ao valor em dívida).
  - Página de detalhe da fatura com histórico completo de pagamentos.
- Dashboard com indicadores de negócio, total faturado, alertas de stock baixo e **resumo financeiro:**
  - Total recebido de todas as faturas.
  - Total em dívida.
  - Contadores de faturas pagas, parciais e não pagas.
- Emissão de faturas com cálculo automático de subtotal, IVA e total.
- Geração, impressão, partilha de PDF e exportação para Excel (CSV).
- Persistência local com Hive (funciona offline).
- Sistema de backup e restauro de dados.
- Configurações da empresa editáveis diretamente na app:
  - Nome da empresa.
  - Taxas de IVA disponíveis.
  - Unidades de produto.
  - Estados de fatura.
  - **Meios de pagamento personalizáveis.**
- Acesso às configurações protegido por PIN de administrador.
- Interface moderna e consistente (gradientes, cartões, feedback visual com SnackBars e diálogos).
- **Sistema de personalização completo:**
  - 10 temas predefinidos profissionais (Azul, Verde, Roxo, Laranja, Teal, Rosa, Índigo, Âmbar, Ciano, Vermelho).
  - Cores personalizadas com seletor de cores completo (primária e secundária).
  - Modo claro, escuro ou automático (segue o sistema).
  - 6 opções de ícones para a aplicação.
  - Ajuste de tamanho de texto (80%-140%).
  - Material You experimental (Android 12+).
  - Todas as preferências salvas automaticamente com Hive.
  - Script de instalação de ícone no sistema Linux incluído.
  - Consulte [PERSONALIZACAO_GUIA.md](PERSONALIZACAO_GUIA.md) para guia completo.

## Principais novidades

- Novo sistema de ícones e splash screen, com visual unificado da marca.
- **Sistema de personalização completo:** 10 temas predefinidos, cores personalizadas, modo claro/escuro/sistema, 6 ícones, tamanho de texto ajustável (80%-140%) e Material You experimental. Todas as preferências salvas automaticamente. Inclui script de instalação de ícone para Linux.
- **Sistema de tutorial interativo:** Tutorial de boas-vindas com 8 slides explicativos sobre as principais funcionalidades, navegação intuitiva (pular, voltar, próximo) e opção de resetar nas configurações.
- **Sistema completo de gestão de pagamentos:** Múltiplos pagamentos parciais por fatura, 10 meios de pagamento configuráveis, status visual com barra de progresso, histórico completo com validações automáticas.
- Sistema de backup para ficheiro JSON e restauro posterior.
- Área de Configurações da Empresa com opções dinâmicas persistidas em base de dados local.
- Segurança por PIN de administrador para proteção de configurações sensíveis.
- Exportação automática de pacotes por plataforma para pastas separadas dentro do projeto.
- Task do VS Code para exportação com um clique.

### Melhorias Recentes

- ✅ **Padronização de espaçamentos:** Todo o código agora segue rigorosamente o grid de 8dp do Material Design (8, 16, 24, 32px).
- ✅ **Correção de overflow na splash screen:** Adicionado scroll para dispositivos com telas pequenas.
- ✅ **Correção de texto fora da caixa no dashboard:** Cards e chips financeiros agora adaptam-se a ecrãs pequenos e fontes maiores com `Wrap`, `FittedBox` e `ellipsis`.
- ✅ **Correção de erros de tipo no dashboard:** Corrigidos nomes de chaves no resumo de pagamentos (`faturasCompletamentePagas`, `faturasParcialmentePagas`).
- ✅ **Compatibilidade Flutter 3.27+:** Corrigida depreciação de `Color.value` para `Color.toARGB32()`.
- ✅ **Sistema de ícones instalável:** Script bash para instalação automática do ícone no ambiente Linux desktop.
- ✅ **Ícones mobile atualizados:** Aplicação de ícones no Android e iOS com integração nativa (Android launcher aliases + iOS alternate icons).
- ✅ **Importação de backup no mobile corrigida:** Seleção de ficheiros mais robusta em Android/iOS com validação de extensão no restauro.
- ✅ **Correção de bloqueio nas Configurações da Empresa:** Inicialização segura do `AdminAuthService` para evitar `LateInitializationError` ao validar PIN.

## Requisitos

- Flutter SDK (estável) instalado e configurado.
- Dart incluído no Flutter SDK.
- Android SDK (para builds Android).
- Linux toolchain (para build Linux, se aplicável).
- VS Code (opcional, para execução por task).

### Dependências Principais

O projeto utiliza as seguintes dependências chave:

- **flutter_riverpod** (^2.6.1) - Gestão de estado reativa
- **hive** (^2.2.3) & **hive_flutter** (^1.1.0) - Persistência local de dados
- **go_router** (^14.6.2) - Navegação e rotas
- **uuid** (^4.5.1) - Geração de IDs únicos
- **intl** (^0.20.1) - Formatação de datas e números
- **pdf** (^3.11.1) - Geração de PDFs
- **path_provider** (^2.1.5) - Acesso a diretórios do sistema
- **file_picker** (^8.1.4) - Seleção de ficheiros
- **printing** (^5.14.1) - Impressão e partilha de PDFs
- **share_plus** (^10.1.3) - Partilha de ficheiros
- **csv** (^6.0.0) - Exportação para Excel/CSV
- **qr_flutter** (^4.1.0) - Geração de QR Codes
- **flutter_colorpicker** (^1.1.0) - Seletor de cores para personalização

Todas as dependências são instaladas automaticamente com `flutter pub get`.

## Instalação correta (passo a passo)

Guia por sistema operativo (Linux, Windows, macOS, iOS, Android e Web): `INSTALACAO_MULTIPLATAFORMA.md`

1. Entrar na pasta do projeto:

```bash
cd /media/huskydb/FicheirosA/IEFP/Facturio
```

2. Instalar dependências:

```bash
flutter pub get
```

3. Validar o projeto:

```bash
flutter analyze
```

**Status atual:** ✅ No issues found!

4. Executar em modo de desenvolvimento (exemplos):

```bash
# Android (dispositivo ligado)
flutter run -d android

# Linux desktop
flutter run -d linux

# Web
flutter run -d chrome
```

## Checklist de Commit Seguro

Use esta sequência para fazer commit sem risco de estragar o código atual:

1. Confirmar estado local:

```bash
git status
```

2. Sincronizar com remoto antes de editar:

```bash
git fetch origin
git pull --rebase origin main
```

3. Validar o projeto antes de commit:

```bash
flutter analyze
# opcional
flutter test
```

4. Adicionar apenas os ficheiros necessários (evitar `git add .`):

```bash
git add caminho/do/ficheiro.dart
git add README.md
```

5. Rever o que vai entrar no commit:

```bash
git diff --staged
```

6. Criar commit com mensagem clara:

```bash
git commit -m "feat: descricao objetiva"
```

7. Publicar no GitHub:

```bash
git push origin main
```

Boas práticas:
- Não comitar com conflitos (`<<<<<<<`, `=======`, `>>>>>>>`).
- Não misturar funcionalidade, refatoração e docs no mesmo commit.
- Preferir commits pequenos e frequentes.

## Tutorial Interativo

O Facturio inclui um **sistema de tutorial de boas-vindas** que é exibido automaticamente na primeira execução:

### Funcionalidades do Tutorial

- **8 slides interativos** sobre as principais funcionalidades
- **Navegação intuitiva:** botões Pular, Voltar, Próximo/Começar
- **Design responsivo** com ícones coloridos e animações suaves
- **Indicadores de progresso** (bolinhas na parte inferior)
- **Swipe horizontal** para navegar entre slides

### Conteúdo Apresentado

1. **Boas-vindas** - Visão geral do sistema
2. **Gestão de Clientes** - Cadastro e histórico
3. **Catálogo de Produtos** - Stock e preços
4. **Faturação Profissional** - Conformidade legal e QR Code AT
5. **Sistema de Pagamentos** - Pagamentos parciais e múltiplos meios
6. **Impressão e Partilha** - PDF e exportação Excel
7. **Dashboard Inteligente** - Indicadores e resumos financeiros
8. **Configurações** - Personalização e backup

### Rever o Tutorial

Para ver o tutorial novamente:
1. Ir para **Configurações da Empresa** (menu lateral)
2. Aba **"Dados Básicos"** (primeira aba)
3. Seção **"Ajuda e Tutorial"**
4. Clicar em **"Ver Tutorial"**

Consulte [TUTORIAL_SISTEMA.md](TUTORIAL_SISTEMA.md) para informações técnicas detalhadas.

## Sistema de Personalização

O Facturio oferece um **sistema completo de personalização** que permite adaptar totalmente a aparência da aplicação às suas preferências.

### Funcionalidades de Personalização

#### 🎨 Temas Predefinidos

Escolha entre **10 temas profissionais** cuidadosamente desenhados:

1. **Azul Profissional** - Tema padrão azul elegante e profissional
2. **Verde Natureza** - Tons de verde suaves e relaxantes
3. **Roxo Criativo** - Roxo vibrante e moderno
4. **Laranja Energia** - Laranja energético e dinâmico
5. **Teal Moderno** - Teal contemporâneo e sofisticado
6. **Rosa Elegante** - Rosa suave e elegante
7. **Índigo Tecnológico** - Índigo tech e inovador
8. **Âmbar Quente** - Âmbar acolhedor e caloroso
9. **Ciano Fresco** - Ciano fresco e limpo
10. **Vermelho Intenso** - Vermelho intenso e impactante

#### 🌈 Cores Personalizadas

- Crie seu próprio tema com **cores exclusivas**
- Seletor de cores completo com paleta RGB
- Personalize **cor primária** e **cor secundária** independentemente
- Pré-visualização em tempo real das alterações

#### 🌓 Modo de Tema

- **Modo Claro**: Interface clara e luminosa
- **Modo Escuro**: Interface escura para reduzir fadiga ocular
- **Modo Sistema**: Sincroniza automaticamente com as preferências do sistema operacional

#### 🎯 Ícones da Aplicação

Escolha entre **6 ícones diferentes** para a aplicação:
- Padrão (Recibo)
- Calculadora
- Dinheiro
- Documentos
- Gráfico
- Negócios

#### 📝 Tamanho de Texto

- Ajuste o tamanho do texto de **80% a 140%**
- Slider intuitivo com pré-visualização em tempo real
- Ideal para melhorar a legibilidade

#### ✨ Material You (Experimental)

- Tema dinâmico baseado no sistema (Android 12+)
- Cores extraídas do papel de parede do dispositivo
- **Nota:** Funcionalidade experimental, pode não funcionar em todos os dispositivos

### Como Personalizar

1. **Aceder à Personalização:**
   - Menu lateral → **Personalização**
   - Ou: Configurações da Empresa → Aba "Dados Básicos" → **Personalização**

2. **Escolher Tema:**
   - Toque num dos 10 temas predefinidos
   - Ou crie cores personalizadas usando os seletores

3. **Ajustar Preferências:**
   - Selecione o modo (Claro/Escuro/Sistema)
   - Escolha um ícone para a aplicação
   - Ajuste o tamanho do texto
   - Ative Material You (opcional)

4. **Reset às Configurações Padrão:**
   - Botão no canto superior direito (ícone de reset)
   - Restaura tema Azul Profissional e todas as configurações iniciais

### Instalação de Ícone no Sistema (Linux)

Para instalar o ícone da aplicação no ambiente desktop Linux:

```bash
cd /media/huskydb/FicheirosA/IEFP/Facturio
bash install_icon.sh
```

O script realiza automaticamente:
- Copia os ícones para `~/.local/share/icons/hicolor/` (16x16 até 512x512)
- Instala o atalho em `~/.local/share/applications/Facturio.desktop`
- Atualiza o cache de ícones do sistema
- O ícone aparecerá no menu de aplicações do sistema

**Nota:** A personalização de ícone dentro da aplicação é apenas visual (UI). Para alterar o ícone do sistema, use o script de instalação.

### Persistência

Todas as suas preferências de personalização são **automaticamente salvas** usando Hive e persistem entre sessões. Não é necessário clicar em "Salvar" - as alterações são aplicadas e guardadas instantaneamente.

### Guia Técnico

Para informações técnicas detalhadas sobre implementação, estrutura de dados e personalização avançada, consulte [PERSONALIZACAO_GUIA.md](PERSONALIZACAO_GUIA.md).

## Sistema de Pagamentos

O Facturio inclui um sistema completo de gestão de pagamentos com as seguintes funcionalidades:

### Funcionalidades Principais

- **Múltiplos pagamentos parciais:** Cada fatura pode ter vários pagamentos registados, permitindo cobranças em prestações.
- **10 meios de pagamento:** Numerário, Transferência Bancária, Multibanco, MB Way, Cheque, Cartão de Crédito, Cartão de Débito, PayPal, Dinheiro e Outros.
- **Validações automáticas:** O sistema impede registar pagamentos superiores ao valor em dívida.
- **Cálculos automáticos:** Total pago, valor em dívida, percentagem paga (0-100%).
- **Status visual:** Barra de progresso com cores (verde=paga, laranja=parcial, vermelho=não paga).
- **Histórico completo:** Lista de todos os pagamentos com data, valor, meio, referência e observações.

### Como Usar

1. **Na lista de faturas:** Clique em "Ver Detalhes" para abrir a página de detalhe da fatura.
2. **Na página de detalhe:** Veja o status de pagamento com barra de progresso e o histórico completo.
3. **Adicionar pagamento:** Clique no botão flutuante "Adicionar Pagamento".
4. **Preencher formulário:**
   - Valor do pagamento (máximo: valor em dívida).
   - Meio de pagamento (selecione da lista).
   - Data do pagamento.
   - Referência (opcional): número de cheque, referência de transferência, etc.
   - Observações (opcional): notas adicionais.
5. **Confirmar:** O pagamento é registado e o status da fatura é atualizado automaticamente.

### Dashboard Financeiro

O dashboard mostra um resumo financeiro completo:
- **Total Recebido:** Soma de todos os pagamentos.
- **Em Dívida:** Total de valores ainda por receber.
- **Faturas Pagas:** Número de faturas totalmente pagas.
- **Faturas Parciais:** Número de faturas com pagamento parcial.
- **Faturas Não Pagas:** Número de faturas sem pagamentos.

### Estrutura de Dados

Os pagamentos são persistidos no Hive com TypeId 3 e incluem:
- `id`: Identificador único (UUID).
- `faturaId`: Referência à fatura.
- `valor`: Valor pago.
- `meioPagamento`: Meio utilizado.
- `dataPagamento`: Data do pagamento.
- `referencia`: Referência do pagamento (opcional).
- `observacoes`: Notas adicionais (opcional).
- `dataCriacao`: Data de registo do pagamento.

### Exemplos Práticos

Consulte o ficheiro [lib/features/pagamentos/EXEMPLOS_USO.md](lib/features/pagamentos/EXEMPLOS_USO.md) para exemplos de código e casos de uso avançados.

## Acesso de administrador (PIN)

- O menu `Configurações da Empresa` pede PIN de administrador.
- PIN predefinido: `1234`.
- Recomenda-se alterar o PIN na própria app:
  - `Configurações da Empresa` -> `Alterar PIN de administrador`.

## Exportar pacotes de instalação

### Opção A: Script automático (recomendado)

Executa tudo e organiza os resultados por plataforma:

```bash
./export_packages.sh
```

Resultado:

- É criada uma pasta com timestamp em `dist/`.
- Exemplo: `dist/20260309_223631/`.
- Dentro dessa pasta, cada sistema fica separado:
  - `android/` -> `Facturio.apk` e `Facturio.aab`
  - `web/` -> build web completo + pacote `Facturio-web.zip`
  - `linux/` -> bundle Linux + pacote `Facturio-linux.tar.gz`
  - `ios/`, `macos/`, `windows/` -> `SKIPPED.txt` quando a build não é suportada no ambiente atual

### Opção B: VS Code (um clique)

1. Abrir o Command Palette.
2. Executar `Tasks: Run Task`.
3. Selecionar `Facturio: Exportar pacotes`.

## Estrutura relevante do projeto

```text
Facturio/
├── lib/
│   ├── app/                    # Configuração principal da app
│   │   ├── app.dart
│   │   ├── routes.dart         # Rotas GoRouter
│   │   └── theme.dart
│   ├── core/                   # Núcleo da aplicação
│   │   ├── models/             # Modelos de dados
│   │   │   └── app_theme.dart  # 10 temas + 6 ícones predefinidos
│   │   ├── providers/          # Providers Riverpod
│   │   │   └── theme_provider.dart  # Gestão de estado de temas
│   │   ├── services/           # Serviços da aplicação
│   │   │   ├── theme_service.dart   # Persistência de preferências
│   │   │   ├── storage_service.dart # Hive boxes
│   │   │   ├── pdf_service.dart     # Geração de PDFs
│   │   │   └── ...
│   │   └── utils/              # Utilitários
│   ├── features/               # Features modulares
│   │   ├── personalizacao/     # Sistema de personalização
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           └── personalizacao_page.dart
│   │   ├── tutorial/           # Tutorial interativo
│   │   ├── pagamentos/         # Sistema de pagamentos
│   │   ├── dashboard/          # Dashboard e estatísticas
│   │   ├── clientes/           # Gestão de clientes
│   │   ├── produtos/           # Catálogo de produtos
│   │   ├── faturas/            # Faturação
│   │   └── configuracoes/      # Configurações da empresa
│   └── shared/                 # Componentes partilhados
├── android/                    # Build Android
├── ios/                        # Build iOS
├── linux/                      # Build Linux
├── web/                        # Build Web
├── dist/                       # Pacotes exportados (criado automaticamente)
├── assets/                     # Assets da aplicação
│   ├── icons/                  # Ícones e splash screens
│   └── images/
├── export_packages.sh          # Script de exportação
├── install_icon.sh             # Script de instalação de ícone (Linux)
├── README.md                   # Este ficheiro
├── PERSONALIZACAO_GUIA.md      # Guia de personalização
└── TUTORIAL_SISTEMA.md         # Documentação do tutorial
```

## Notas importantes

- iOS e macOS exigem ambiente macOS com Xcode para build nativa.
- Windows exige ambiente Windows para build nativa.
- A exportação automática cria ficheiros `SKIPPED.txt` para plataformas não suportadas no sistema atual.
- Antes de publicar na Play Store, garantir assinatura release corretamente configurada.

## Qualidade de Código

O projeto segue rigorosamente os padrões de qualidade do Flutter:

### Padrões de Design

- ✅ **Material Design 3** - Toda a UI segue as guidelines do Material 3
- ✅ **Grid de 8dp** - Todos os espaçamentos seguem múltiplos de 8 (8, 16, 24, 32, 40px)
- ✅ **Arquitetura em camadas** - Separação clara entre UI, lógica e dados
- ✅ **Feature-first structure** - Código organizado por funcionalidades
- ✅ **Clean Code** - Código limpo, comentado e autodocumentado

### Validação

```bash
flutter analyze
# ✅ No issues found!
```

O código é validado regularmente e mantém **zero erros e zero warnings**.

### Testes

- Testes unitários para serviços críticos
- Testes de integração para fluxos principais
- Validação manual em múltiplas plataformas (Android, Linux, Web)

### Acessibilidade

- Suporte para modo escuro
- Tamanho de texto ajustável (80%-140%)
- Contraste adequado em todos os temas
- Navegação por teclado funcional

### Performance

- Persistência local com Hive (operações em menos de 1ms)
- Gestão de estado eficiente com Riverpod
- Builds otimizadas para produção
- Lazy loading de listas longas

## Licença

Uso interno/projeto privado.
