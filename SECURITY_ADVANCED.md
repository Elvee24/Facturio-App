# 🛡️ Proteção contra Ataques Hackers Avançados

## Documento de Segurança Avançada - Facturio

**Data**: 11 de Março de 2026  
**Versão**: 2.0.0+1  
**Nível de Segurança**: CRÍTICO (Anti-Hacker Avançado)

---

## 📋 Índice de Proteções

1. [Validação de Entrada](#1-validação-rigorosa-de-entrada)
2. [Integridade de Dados](#2-verificação-de-integridade)
3. [Rate Limiting](#3-rate-limiting-avançado)
4. [Detecção de Anomalias](#4-detecção-de-anomalias-comportamentais)
5. [Monitoramento em Tempo Real](#5-monitoramento-de-segurança-em-tempo-real)
6. [Anti-Debugging](#6-proteção-contra-reverse-engineering)
7. [Sanitização de Entrada](#7-sanitização-de-entrada)
8. [CSRF Protection](#8-proteção-contra-csrf)

---

## 1. ✅ Validação Rigorosa de Entrada

### Serviço: `InputValidationService`

**Proteção contra:**
- SQL Injection
- Path Traversal  
- Script Injection (XSS)
- Command Injection
- Ficheiros maliciosos

### Características:
```dart
// Validar entrada de texto contra injeção
final result = InputValidationService.validateTextInput(
  userInput,
  minLength: 1,
  maxLength: 255,
  allowSpecialChars: false,
);

if (!result.isValid) {
  print('Input suspeito: ${result.message}');
}

// Validar NIF (Portugal) com checksum
if (!InputValidationService.isValidNIF('123456789')) {
  throw Exception('NIF inválido');
}

// Validar IBAN (Portugal) com checksum IBANDE
if (!InputValidationService.isValidIBAN('PT50000200051000020051')) {
  throw Exception('IBAN inválido');
}

// Validar Email com rigor
if (!InputValidationService.isValidEmail('user@example.com')) {
  throw Exception('Email inválido');
}

// Validar número (quantidade, preço)
final numResult = InputValidationService.validateNumber(
  '100.50',
  minValue: 0.0,
  maxValue: 1000.0,
  decimalPlaces: 2,
);

// Validar caminho de arquivo (prevenir path traversal)
final pathResult = InputValidationService.validateFilePath(
  'uploads/document.pdf'
);

// Validar UUID
if (InputValidationService.isValidUUID(someId)) {
  // ID válido
}

// Sanitizar entrada (remover caracteres perigosos)
final safe = InputValidationService.sanitizeInput(userInput);
```

**RegEx Patterns Utilizados:**
- SQL Injection: `('|(--)|(/\*)|(;\s*DROP)|(\bOR\b|\bAND\b))`
- Path Traversal: `(\.\./|\.\.\\|%2e%2e)`
- Script Injection: `(<script|javascript:|onerror=|onload=)`
- Command Injection: `([;|&`$(){}[\]<>]|bash|sh)`

---

## 2. 🔍 Verificação de Integridade

### Serviço: `IntegrityCheckService`

**Proteção contra:**
- Manipulação de dados
- Corrupção de ficheiros
- Alteração de configurações

### Características:
```dart
// Gerar checksum HMAC para dados
final checksum = IntegrityCheckService.generateChecksum(
  'dados sensíveis',
  'chave secreta',
);

// Verificar integridade
if (!IntegrityCheckService.verifyChecksum(dados, checksum, 'chave')) {
  throw Exception('Dados foram manipulados!');
}

// Gerar assinatura digital para estrutura de dados
final signature = IntegrityCheckService.generateDataSignature(
  {'nif': '123456789', 'nome': 'João'},
  'chave secreta',
);

// Verificar assinatura
if (!IntegrityCheckService.verifyDataSignature(data, signature, 'chave')) {
  throw Exception('Dados foram alterados!');
}

// Gerar Merkle root para validar lista inteira
final merkleRoot = IntegrityCheckService.generateMerkleRoot(
  ['item1', 'item2', 'item3'],
  'chave',
);

// Detectar manipulação de arquivo
if (IntegrityCheckService.detectFileManipulation(content, original, 'chave')) {
  throw Exception('Arquivo foi modificado!');
}

// Detectar mudanças não autorizadas
final changes = IntegrityCheckService.detectUnauthorizedChanges(
  expectedState,
  actualState,
);
```

**Algoritmo**: HMAC-SHA256 com Merkle Tree

---

## 3. ⏱️ Rate Limiting Avançado

### Serviço: `RateLimiterService`

**Proteção contra:**
- Brute Force Attacks
- DDoS (Denial of Service)
- Força Bruta de PIN
- Abuso de API

### Limites Configurados:
```dart
operationLimits = {
  'login': 5 requisições / 60 segundos,
  'export': 10 requisições / 3600 segundos,
  'import': 10 requisições / 3600 segundos,
  'delete': 20 requisições / 3600 segundos,
  'api_call': 100 requisições / 60 segundos,
  'file_upload': 5 requisições / 300 segundos,
  'data_sync': 30 requisições / 3600 segundos,
};
```

### Uso:
```dart
// Verificar se operação é permitida
final result = RateLimiterService.checkRateLimit(
  'login',
  userId: userId,
);

if (!result.allowed) {
  print('Bloqueado por: ${result.message}');
  print('Tente novamente em: ${result.resetIn.inSeconds}s');
}

// Detectar padrão de força bruta
if (RateLimiterService.detectBruteForcePattern('login', userId: userId)) {
  // Aplicar medidas de segurança
}

// Calcular backoff exponencial
final backoff = RateLimiterService.calculateBackoffDuration(
  failureCount,
  baseDuration: Duration(seconds: 1),
  maxMultiplier: 32,
);

// Obter status
final status = RateLimiterService.getStatus('login', userId: userId);
print('${status.currentRequests}/${status.maxRequests} utilizados');
```

---

## 4. 🚨 Detecção de Anomalias Comportamentais

### Serviço: `AnomalyDetectionService`

**Detecção de:**
- Padrões de ataque automatizado
- Acesso geográficamente impossível
- Ações incomuns do utilizador
- Acesso fora de horários normais
- Operações em massa suspeitas

### Uso:
```dart
// Registar atividade
await AnomalyDetectionService.recordActivity(
  userId,
  'delete_cliente',
  {'cliente_id': '123', 'timestamp': DateTime.now()},
);

// Detectar anomalias
final result = AnomalyDetectionService.detectAnomalies(userId);
if (result.hasAnomalies) {
  print('Anomalias detectadas: ${result.anomalies}');
  print('Nível de risco: ${result.riskLevel.name}');
}

// Verificar se ação é suspeita
if (AnomalyDetectionService.isSuspiciousAction(userId, 'export_all')) {
  // Pedir confirmação adicional
}
```

**Padrões Detectados:**
1. ✅ Múltiplas ações em < 5 segundos
2. ✅ Acesso geograficamente impossível
3. ✅ Ações incomuns (não no histórico)
4. ✅ Acesso fora 09:00-18:00
5. ✅ Operações delete/export em sequência

---

## 5. 📊 Monitoramento de Segurança em Tempo Real

### Serviço: `SecurityMonitorService`

**Monitoramento:**
- Alertas de segurança em tempo real
- Detecção de padrão de ataque
- Análise de risco do sistema
- Histórico de incidentes

### Uso:
```dart
// Gerar alerta
await SecurityMonitorService.generateAlert(
  title: 'Tentativa de acesso não autorizado',
  description: 'Múltiplas PINs inválidas detectadas',
  severity: AlertSeverity.high,
  type: AlertType.authenticationFailure,
  context: {'userId': userId, 'attempts': 5},
);

// Detectar padrão de ataque
if (SecurityMonitorService.detectAttackPattern()) {
  // Sistema sob ataque - aplicar proteções
  await _emergencyLockdown();
}

// Obter alertos ativos
final alerts = SecurityMonitorService.getActiveAlerts(
  minimumSeverity: AlertSeverity.high,
);

// Análise geral de segurança
final analysis = SecurityMonitorService.getSecurityAnalysis();
print('Status: ${analysis.status.description}');
print('Alertas críticos: ${analysis.criticalAlerts}');

// Exportar relatório
final report = await SecurityMonitorService.exportSecurityReport();
```

**Níveis de Alerta:**
- LOW: Aviso
- MEDIUM: Monitorar
- HIGH: Investigar
- CRITICAL: Ação urgente

---

## 6. 🔒 Proteção contra Reverse Engineering

### Serviço: `AntiDebuggingService`

**Proteção contra:**
- Debugging/Breakpoints
- Emuladores
- Ferramentas de análise
- Modificação de ficheiros executáveis

### Uso:
```dart
// Verificar se está em debug mode
if (AntiDebuggingService.isDebugMode()) {
  // Sair da aplicação em modo debug
  exit(1);
}

// Verificar se está em emulador
if (await AntiDebuggingService.isEmulator()) {
  throw SecurityException('Emuladores não são suportados');
}

// Verificar se há ferramentas de debug
if (await AntiDebuggingService.hasDebugTools()) {
  // Notificar utilizador ou sair
}

// Detectar modificação de ficheiros
if (await AntiDebuggingService.detectFileModification('/app/executable')) {
  throw SecurityException('Ficheiro foi modificado');
}

// Obfuscar informações sensíveis
final masked = AntiDebuggingService.obfuscateSensitiveData('senha123');
// Resultado: se****23

// Verificar integridade da app
final signatures = await AntiDebuggingService.calculateAppSignature([
  '/app/main.dart',
  '/app/android/app.apk',
]);

if (!await AntiDebuggingService.verifyAppIntegrity(signatures, files)) {
  throw SecurityException('Integridade da app comprometida');
}
```

---

## 7. 🧹 Sanitização de Entrada

### Serviço: `InputSanitizationService`

**Remove:**
- Tags HTML/JS
- Caracteres de controle
- Null bytes
- Caracteres especiais perigosos

### Uso:
```dart
// Remover tags HTML
final clean = InputSanitizationService.sanitizeHtml(userInput);

// Codificar para HTML
final encoded = InputSanitizationService.encodeHtmlEntities('<script>');
// Resultado: &lt;script&gt;

// Remover caracteres de controle
final safe = InputSanitizationService.removeControlCharacters(input);

// Normalizar whitespace
final normalized = InputSanitizationService.normalizeWhitespace(input);

// Escapar para SQL
final sqlSafe = InputSanitizationService.escapeSql(userInput);

// Sanitizar nome de ficheiro
final filename = InputSanitizationService.sanitizeFileName('../../etc/passwd');
// Resultado: ___etc_passwd

// Sanitizar URL
final url = InputSanitizationService.sanitizeUrl(userUrl);

// Verificar comando é seguro
if (!InputSanitizationService.isSafeCommand(command)) {
  throw SecurityException('Comando perigoso detectado');
}

// Sanitizar lista completa
final safe = InputSanitizationService.sanitizeList(itemList);

// Sanitizar mapa (objeto JSON)
final cleanData = InputSanitizationService.sanitizeMap(jsonData);
```

---

## 8. 🛡️ Proteção contra CSRF (Cross-Site Request Forgery)

### Serviço: `CsrfProtectionService`

**Proteção:**
- Tokens CSRF únicos por requisição
- One-time use tokens
- Expiração de tokens (60 minutos)
- Validação de origem

### Uso:
```dart
// Gerar token CSRF
final token = await CsrfProtectionService.generateToken(userId);

// Validar token
if (!await CsrfProtectionService.validateToken(token, userId)) {
  throw SecurityException('Token CSRF inválido ou expirado');
}

// Invalidar todos os tokens de um utilizador
await CsrfProtectionService.invalidateUserTokens(userId);

// Verificar se origem é válida
if (!SameSiteProtectionService.isSameOrigin(requestOrigin, expectedOrigin)) {
  throw SecurityException('Requisição de origem não autorizada');
}

// Validar referrer
if (!SameSiteProtectionService.isValidReferrer(referrer, expectedOrigin)) {
  throw SecurityException('Referrer inválido');
}
```

---

## 🎯 Resumo de Proteções

| Ataque | Proteção | Serviço |
|--------|----------|---------|
| SQL Injection | RegEx + Validação | InputValidationService |
| XSS/Script Injection | Sanitização HTML | InputSanitizationService |
| Path Traversal | Validação caminho | InputValidationService |
| Command Injection | Sanitização shell | InputSanitizationService |
| Brute Force Login | Rate Limiting | RateLimiterService |
| DDoS | Rate Limiting + Threshold | RateLimiterService |
| Manipulação Dados | HMAC + Merkle Tree | IntegrityCheckService |
| Automatização | Detecção padrão | AnomalyDetectionService |
| Reverse Engineering | Anti-Debug + Integrity | AntiDebuggingService |
| CSRF | Token único descartável | CsrfProtectionService |
| Comportamento Anormal | Perfil utilizador | AnomalyDetectionService |
| Ataque em Tempo Real | Monitoramento contínuo | SecurityMonitorService |

---

## 🚀 Inicialização no main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar todos os serviços de segurança
  await AdminAuthService.init();
  await SecureDataService.init();
  await FileSecurityService.getSecureAppDataDirectory();
  await AnomalyDetectionService.init();
  await SecurityMonitorService.init();
  await CsrfProtectionService.init();
  
  // Verificar integridade imediatamente
  if (await AntiDebuggingService.isEmulator()) {
    exit(1);
  }
  
  if (AntiDebuggingService.isDebugMode()) {
    exit(1);
  }

  runApp(const FacturioApp());
}
```

---

## 📌 Boas Práticas

1. **Sempre validar entrada** com `InputValidationService`
2. **Sanitizar dados** com `InputSanitizationService`
3. **Verificar integridade** com `IntegrityCheckService`
4. **Monitorar atividades** com `AnomalyDetectionService`
5. **Implementar rate limits** para operações críticas
6. **Gerar alertas** para comportamentos suspeitos
7. **Verificar se está em debug** no startup
8. **Usar tokens CSRF** para requisições que alteram dados

---

## 🚨 Resposta a Ataques

Se um ataque for detectado:

1. **Gerar alerta crítico** → SecurityMonitorService
2. **Bloquear utilizador** → AdminAuthService.lockout
3. **Registar incidente** → Audit log
4. **Notificar admin** → Alert system
5. **Exportar relatório** → SecurityMonitorService.exportReport()
6. **Análise forense** → Histórico completo disponível

---

## 📞 Conclusão

Facturio agora possui **proteção em camadas contra ataques hackers avançados**:
- ✅ Validação rigorosa
- ✅ Detecção em tempo real
- ✅ Anti-evasão
- ✅ Monitoramento contínuo
- ✅ Resposta automática

**Segurança: MÁXIMA** 🛡️

Data: 11 Março 2026
Versão: 2.0.0+1
