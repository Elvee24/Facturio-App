# Facturio Flutter

Sistema completo de faturação empresarial desenvolvido em Flutter com arquitetura Clean Architecture.

## 🚀 Funcionalidades

### ✅ Implementadas
- **CRUD Clientes** - Gestão completa de clientes (criar, editar, eliminar, pesquisar)
- **CRUD Produtos** - Gestão de produtos com controlo de stock e IVA
- **CRUD Faturas** - Criação e gestão de faturas
- **Dashboard** - Visão geral com estatísticas e alertas
- **Geração de PDF** - Criação e partilha de faturas em PDF
- **Persistência Local** - Dados guardados localmente com Hive
- **Pesquisa** - Pesquisa inteligente em clientes e produtos
- **Validação** - Formulários com validação completa
- **Tema** - Design Material 3 com suporte para modo escuro

## 📁 Arquitetura

```
lib/
├── app/                      # Configuração da aplicação
│   ├── app.dart              # Widget principal
│   ├── routes.dart           # Navegação (go_router)
│   └── theme.dart            # Tema Material 3
├── core/                     # Funcionalidades centrais
│   ├── constants/            # Constantes (IVA, estados, etc)
│   ├── services/             
│   │   ├── storage_service.dart  # Persistência com Hive
│   │   └── pdf_service.dart      # Geração de PDFs
├── features/                 # Features (Clean Architecture)
│   ├── clientes/
│   │   ├── data/             # Models e Repositories
│   │   ├── domain/           # Entities
│   │   └── presentation/     # Pages, Widgets e Providers
│   ├── produtos/
│   ├── faturas/
│   └── dashboard/
├── shared/                   # Código compartilhado
│   └── models/               # LinhaFatura, etc
└── main.dart                 # Entry point
```

## 🛠️ Tecnologias

- **Flutter** 3.27.x
- **Riverpod** 2.6.1 - Gestão de estado
- **Hive** 2.2.3 - Persistência local NoSQL
- **go_router** 14.8.1 - Navegação declarativa
- **pdf** 3.11.3 - Geração de PDFs
- **printing** 5.14.2 - Preview e impressão
- **intl** - Formatação de datas e moeda
- **uuid** - Geração de IDs únicos

## 📦 Instalação

### Pré-requisitos
- Flutter SDK 3.27.x ou superior
- Dart 3.11.x ou superior

### Passos

1. **Instalar dependências**
```bash
flutter pub get
```

2. **Executar a aplicação**
```bash
# Desktop (Linux)
flutter run -d linux

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 🎯 Uso

### Dashboard
- Visão geral com estatísticas
- Alertas de stock baixo
- Últimas faturas registadas

### Clientes
- Adicionar novo cliente (Nome, NIF, Email, Telefone, Morada)
- Editar clientes existentes
- Eliminar clientes
- Pesquisar por nome, NIF ou email

### Produtos
- Adicionar produtos com preço, IVA e stock
- Diferentes taxas de IVA (23%, 13%, 6%, 0%)
- Várias unidades (un, kg, m, l, etc)
- Alerta visual para stock baixo (<10)

### Faturas
- Criar fatura selecionando cliente e produtos
- Estados: rascunho, emitida, paga, cancelada
- Cálculo automático de subtotais e IVA
- Geração e partilha de PDF
- Numeração automática (Ano/Número)

## 📱 Compatibilidade

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Desktop** (Windows, macOS, Linux)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

## 🔧 Próximos Passos

### Fase 2 - Melhorias
- [ ] Filtros avançados (por data, estado, valor)
- [ ] Gráficos de vendas
- [ ] Exportação de dados (CSV, Excel)
- [ ] Backup/Restore
- [ ] Configurações da empresa
- [ ] Impressão direta

### Fase 3 - Avançado
- [ ] Multi-empresa
- [ ] Sincronização cloud
- [ ] Autenticação de utilizadores
- [ ] Relatórios avançados
- [ ] Envio de faturas por email

## 📝 Notas

1. **Persistência Local**: Os dados são guardados localmente no dispositivo usando Hive.

2. **Sem Autenticação**: Esta versão não tem sistema de login.

3. **PDF Customização**: Edite `pdf_service.dart` para personalizar o layout.

4. **Taxas de IVA**: Configuradas para Portugal (23%, 13%, 6%, 0%).

---

**Desenvolvido com Flutter** 💙
