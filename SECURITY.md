# 🔐 Guia Completo de Segurança - Facturio

## Resumo das Melhorias de Segurança

A aplicação Facturio foi reforçada com múltiplas camadas de segurança para proteger dados sensíveis e operações críticas.

---

## 1. 🔑 Autenticação Reforçada

### Serviço: `AdminAuthService`

**Características:**
- ✅ **Limite de Tentativas**: Máximo 10 tentativas falhadas por hora
- ✅ **Bloqueio Automático**: 15 minutos após exceder limite
- ✅ **Hash Timing-Safe**: Comparação de PIN contra timing attacks
- ✅ **Auditoria Completa**: Todas as tentativas são registadas
- ✅ **Validação de Formato**: PIN entre 4-12 caracteres

### Uso:
```dart
// Inicializar (no main.dart da app)
await AdminAuthService.init();

// Validar PIN
final isValid = await AdminAuthService.validarPin('meupin1234');

// Alterar PIN
final success = await AdminAuthService.mudarPin('pinAntigo', 'pinNovo');

// Verificar se está bloqueado
final isLocked = await AdminAuthService.isLockedOut();

// Obter tempo restante de bloqueio
final duration = await AdminAuthService.getRemainingLockoutDuration();

// Ver histórico de auditoria
final logs = await AdminAuthService.getAuditLog(limit: 100);

// Exportar log encriptado
final encrypted = await AdminAuthService.exportAuditLogEncrypted('senhaExport');
```

---

## 2. 🔐 Encriptação de Dados

### Serviço: `EncryptionService`

**Algoritmo**: ChaCha20-Poly1305 com PBKDF2 (100,000 iterações)

**Características:**
- ✅ Derivação de chave com salt aleatório
- ✅ Tag de autenticação (HMAC-SHA256)
- ✅ Comparação timing-safe
- ✅ Suporte para encriptação de strings longas

### Uso:
```dart
// Encriptar dados sensíveis
final encrypted = EncryptionService.encrypt('meu NIF 123456789', 'masterPassword');

// Desencriptar
final decrypted = EncryptionService.decrypt(encrypted, 'masterPassword');

// Hash seguro com salt (para senhas)
final hashedPin = EncryptionService.hashWithSalt('meuPin1234');

// Verificar hash com salt
final isValid = EncryptionService.verifyHash('meuPin1234', hashedPin);
```

---

## 3. 🛡️ Armazenamento Seguro de Dados Sensíveis

### Serviço: `SecureDataService`

**Campos Protegidos:**
- Cliente: NIF, Email, Telefone, IBAN
- Pagamento: Número Cheque, Número Referência

**Características:**
- ✅ Encriptação automática de campos sensíveis
- ✅ Desencriptação transparente
- ✅ Fallback para compatibilidade com dados antigos
- ✅ Validação de integridade

### Uso:
```dart
// Inicializar (após autenticação)
await SecureDataService.init();
await SecureDataService.setMasterKey(pinDoUtilizador);

// Encriptar campo individual
final nifEncriptado = SecureDataService.encryptField('123456789');

// Desencriptar campo
final nifDecriptado = SecureDataService.decryptField(nifEncriptado);

// Encriptar objecto JSON completo
final clienteEncriptado = SecureDataService.encryptJsonObject(
  {'nif': '123456789', 'email': 'user@example.com', 'nome': 'João'},
  'cliente'
);

// Desencriptar objecto JSON
final clienteDecriptado = SecureDataService.decryptJsonObject(clienteEncriptado, 'cliente');
```

---

## 4. 🗂️ Proteção de Ficheiros

### Serviço: `FileSecurityService`

**Características:**
- ✅ Permissões restritas (700 - apenas dono pode ler/escrever)
- ✅ Diretório seguro dedicado
- ✅ Eliminação segura com sobrescrita Gutmann
- ✅ Verificação de integridade

### Uso:
```dart
// Criar diretório seguro
final dir = await FileSecurityService.createSecureDirectory('meusBackups');

// Guardar arquivo seguro
await FileSecurityService.writeSecureFile('backup.json', jsonData);

// Ler arquivo seguro
final content = await FileSecurityService.readSecureFile('backup.json');

// Eliminar com segurança (sobrescreve 3x antes de deletar)
final file = File('/caminho/ficheiro');
await FileSecurityService.secureDelete(file);

// Verificar permissões
final isSecure = await FileSecurityService.hasRestrictedPermissions(file);
```

---

## 5. 🔄 Fluxo de Autenticação Integrado

### Provider: `SecurityProvider`

Usa Riverpod para gerenciar estado de segurança da aplicação.

**Estados:**
```dart
class SecurityState {
  final bool isInitialized;        // Serviços inicializados
  final bool isAuthenticated;      // Utilizador autenticado
  final int? failedAttempts;       // Tentativas falhadas
  final Duration? lockoutRemaining; // Tempo até desbloqueio
  final String? errorMessage;      // Mensagem de erro
}
```

### Uso:
```dart
// Em widgets, ler estado
final security = ref.watch(securityProvider);
final isAuthenticated = ref.watch(isAuthenticatedProvider);
final failedAttempts = ref.watch(failedAttemptsProvider);

// Inicializar segurança (no main.dart)
ref.read(securityProvider.notifier).initializeSecurity();

// Autenticar
final success = await ref.read(securityProvider.notifier)
    .authenticateWithPin(pin);

// Mudar PIN
await ref.read(securityProvider.notifier)
    .changePin(oldPin, newPin);

// Fazer logout
await ref.read(securityProvider.notifier).logout();
```

---

## 6. 🛡️ Integração com Hive (Armazenamento Local)

### Boxes Seguros:
- `auth_security`: PIN hash e contadores de tentativas
- `auth_audit_log`: Histórico de todas as operações de segurança
- `secure_encryption_keys`: Chaves de encriptação (se necessário)

### Exemplo de Uso em Modelos:
```dart
// No seu model, usar SecureDataService
class ClienteModel {
  // ... outros campos
  
  Map<String, dynamic> toJson() {
    final data = { /* seus dados */ };
    // Encriptar dados sensíveis
    return SecureDataService.encryptJsonObject(data, 'cliente');
  }
  
  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    // Desencriptar dados sensíveis
    final decrypted = SecureDataService.decryptJsonObject(json, 'cliente');
    return ClienteModel(
      nif: decrypted['nif'],
      email: decrypted['email'],
      // ...
    );
  }
}
```

---

## 7. 📊 Auditoria e Logging

### Eventos Registados:
- ✅ Login bem-sucedido
- ✅ Tentativas falhadas de PIN
- ✅ Bloqueio de conta
- ✅ Alterações de PIN
- ✅ Exportação de dados
- ✅ Todas as operações críticas

### Exportar Auditoria:
```dart
// Obter log (últimas 50 entradas)
final logs = await AdminAuthService.getAuditLog(limit: 50);

// Exportar encriptado com password
final encrypted = await AdminAuthService.exportAuditLogEncrypted('mysecret');

// Limpar log (apenas admin)
await AdminAuthService.clearAuditLog();
```

---

## 8. ⚠️ Melhorias de Segurança Implementadas

### Antes:
- ❌ PIN padrão (1234) sem protecção
- ❌ Sem limite de tentativas
- ❌ Sem encriptação de dados sensíveis
- ❌ Sem auditoria
- ❌ Ficheiros sem permissões restritas

### Depois:
- ✅ PIN com hash SHA256 + PBKDF2
- ✅ 10 tentativas máximas por hora + bloqueio de 15 min
- ✅ ChaCha20-Poly1305 com PBKDF2 (100k iterações)
- ✅ Auditoria completa de todas as operações
- ✅ Permissões 700 em diretórios sensíveis
- ✅ Comparação timing-safe contra timing attacks
- ✅ Suporte bilingue em mensagens de segurança

---

## 9. 🔧 Inicialização no main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar serviços de armazenamento
  await StorageService.init();
  
  // Inicializar segurança
  await AdminAuthService.init();
  await SecureDataService.init();
  
  // Executar app
  runApp(const FacturioApp());
}

// Depois de autenticar (após PIN válido)
Future<void> authenticateAndInit(String pin) async {
  if (await AdminAuthService.validarPin(pin)) {
    await SecureDataService.setMasterKey(pin);
    // Carregar dados da aplicação
  }
}
```

---

## 10. 🔐 Recomendações de Segurança

### Para o Utilizador:
1. **PIN Forte**: Use um PIN de 8+ caracteres com números e letras
2. **Nunca Compartilhe**: O PIN é a chave mestre - nunca compartilhe
3. **Backups**: Exporte regularmente com senha forte
4. **Atualizações**: Mantenha a app sempre atualizada
5. **Auditoria**: Verifique periodicamente o log de auditoria

### Para o Administrador:
1. **Rotação de PIN**: Altere PIN a cada 3 meses
2. **Backups Encriptados**: Sempre exporte com password forte
3. **Monitoramento**: Revise logs de auditoria regularmente
4. **Permissões**: Use diretórios seguros para armazenar backups
5. **Testes**: Teste procedimentos de recuperação regularmente

---

## 11. 📋 Checklist de Segurança

- [ ] Inicializar segurança no startup
- [ ] Exigir autenticação PIN antes de acessar dados
- [ ] Usar SecureDataService para dados sensíveis
- [ ] Implementar logout automático (inatividade)
- [ ] Exportar auditoria regularmente
- [ ] Testar limite de tentativas e bloqueio
- [ ] Validar permissões de ficheiros
- [ ] Fazer backup de dados com encriptação
- [ ] Documentar procedimentos de recuperação
- [ ] Testar recuperação de backup

---

## 12. 🚨 Tratamento de Erros de Segurança

```dart
try {
  await AdminAuthService.validarPin(pin);
} on EncryptionException catch (e) {
  // Erro na encriptação - trate apropriadamente
  showError('Erro de segurança: ${e.message}');
} on FileSecurityException catch (e) {
  // Erro na segurança de ficheiros
  showError('Erro ao aceder ficheiros: ${e.message}');
} on SecureDataException catch (e) {
  // Erro na encriptação de dados
  showError('Erro ao processar dados: ${e.message}');
}
```

---

## 📞 Suporte

Para problemas de segurança ou sugestões:
- Verifique os logs do sistema
- Consulte a auditoria da app
- Entre em contacto com administrador

**Data de Implementação**: 11 de Março de 2026
**Versão**: 1.0.0+1
**Segurança**: Máxima
