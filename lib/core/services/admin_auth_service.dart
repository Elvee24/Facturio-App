import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'encryption_service.dart';

/// Serviço seguro de autenticação com limite de tentativas e auditoria
class AdminAuthService {
  static const String defaultPin = '1234';
  static final String defaultPinHash = hashPin(defaultPin);
  
  // Constantes de segurança
  static const int maxAttemptsPerHour = 10;
  static const int lockoutDurationMinutes = 15;
  static const int pinMinLength = 4;
  static const int pinMaxLength = 12;

  static late Box<dynamic> _authBox;
  static late Box<dynamic> _auditBox;
  static bool _initialized = false;

  // Inicializar serviço (deve ser chamado na inicialização da app)
  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    _authBox = await Hive.openBox<dynamic>('auth_security');
    _auditBox = await Hive.openBox<dynamic>('auth_audit_log');
    
    // Inicializar PIN padrão se não existir
    if (!_authBox.containsKey('pin_hash')) {
      await _authBox.put('pin_hash', defaultPinHash);
    }
    
    // Inicializar contador de tentativas
    if (!_authBox.containsKey('failed_attempts')) {
      await _authBox.put('failed_attempts', 0);
    }
    
    // Inicializar última tentativa falha
    if (!_authBox.containsKey('last_failed_attempt')) {
      await _authBox.put('last_failed_attempt', DateTime.now().millisecondsSinceEpoch);
    }

    // Limpar tentativas antigas
    await _cleanupOldAttempts();
    _initialized = true;
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await init();
  }

  // Hash PIN com SHA256
  static String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  // Validar PIN com proteção contra timing attacks
  static Future<bool> validarPin(String pin) async {
    try {
      await _ensureInitialized();

      // Verificar se está em bloqueio
      if (await isLockedOut()) {
        await _logFailedAttempt(pin, 'Account locked out');
        return false;
      }

      // Validar formato
      if (!_isValidPinFormat(pin)) {
        await _logFailedAttempt(pin, 'Invalid PIN format');
        return false;
      }

      final storedHash = _authBox.get('pin_hash') as String;
      final inputHash = hashPin(pin);
      
      // Comparação timing-safe
      final isValid = _constantTimeEquals(inputHash, storedHash);

      if (isValid) {
        // Reset de tentativas falhadas
        await _authBox.put('failed_attempts', 0);
        await _logSuccessfulAttempt(pin);
        return true;
      } else {
        // Incrementar contador de tentativas falhadas
        final failedAttempts = (_authBox.get('failed_attempts') as int? ?? 0) + 1;
        await _authBox.put('failed_attempts', failedAttempts);
        await _authBox.put('last_failed_attempt', DateTime.now().millisecondsSinceEpoch);
        await _logFailedAttempt(pin, 'Invalid PIN');
        
        // Bloqueie se excedeu tentativas
        if (failedAttempts >= maxAttemptsPerHour) {
          await _logSecurityEvent('Multiple failed PIN attempts - Account locked');
        }
        
        return false;
      }
    } catch (e) {
      await _logSecurityEvent('Error during PIN validation: $e');
      return false;
    }
  }

  // Mudar PIN com validação rigorosa
  static Future<bool> mudarPin(String pinAntigo, String pinNovo) async {
    try {
      await _ensureInitialized();

      // Validar PIN antigo
      if (!await validarPin(pinAntigo)) {
        await _logSecurityEvent('Failed attempt to change PIN - invalid old PIN');
        return false;
      }

      // Validar novo PIN
      if (!_isValidPinFormat(pinNovo)) {
        await _logSecurityEvent('Invalid new PIN format');
        return false;
      }

      // Evitar PIN idêntico ao anterior
      if (pinAntigo == pinNovo) {
        await _logSecurityEvent('Attempted to set new PIN identical to old PIN');
        return false;
      }

      // Hashear e guardar novo PIN
      final newHash = hashPin(pinNovo);
      await _authBox.put('pin_hash', newHash);
      await _logSecurityEvent('PIN successfully changed');
      
      return true;
    } catch (e) {
      await _logSecurityEvent('Error changing PIN: $e');
      return false;
    }
  }

  // Verificar se conta está bloqueada
  static Future<bool> isLockedOut() async {
    try {
      await _ensureInitialized();

      final failedAttempts = _authBox.get('failed_attempts') as int? ?? 0;
      
      if (failedAttempts < maxAttemptsPerHour) {
        return false;
      }

      final lastFailedTime = (_authBox.get('last_failed_attempt') as int?) ?? 0;
      final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lastFailedTime)
          .add(Duration(minutes: lockoutDurationMinutes));
      
      if (DateTime.now().isAfter(lockoutUntil)) {
        // Bloqueio expirou, reset
        await _authBox.put('failed_attempts', 0);
        return false;
      }

      return true;
    } catch (e) {
      return true; // Bloqueio por padrão se há erro
    }
  }

  // Obter tempo restante até desbloqueio
  static Future<Duration?> getRemainingLockoutDuration() async {
    try {
      await _ensureInitialized();

      final failedAttempts = _authBox.get('failed_attempts') as int? ?? 0;
      
      if (failedAttempts < maxAttemptsPerHour) {
        return null;
      }

      final lastFailedTime = (_authBox.get('last_failed_attempt') as int?) ?? 0;
      final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lastFailedTime)
          .add(Duration(minutes: lockoutDurationMinutes));
      
      final remaining = lockoutUntil.difference(DateTime.now());
      
      if (remaining.isNegative) {
        return null;
      }

      return remaining;
    } catch (e) {
      return null;
    }
  }

  // Validar formato do PIN
  static bool _isValidPinFormat(String pin) {
    if (pin.isEmpty || pin.length < pinMinLength || pin.length > pinMaxLength) {
      return false;
    }
    // PIN deve conter apenas números (e possivelmente caracteres alfabéticos)
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(pin);
  }

  // Comparação timing-safe
  static bool _constantTimeEquals(String a, String b) {
    int result = a.length ^ b.length;
    for (int i = 0; i < a.length && i < b.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // Registar tentativa falhada
  static Future<void> _logFailedAttempt(String pin, String reason) async {
    await _ensureInitialized();
    await _auditBox.add({
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'failed_login_attempt',
      'reason': reason,
      'pin_length': pin.length,
    });
  }

  // Registar tentativa bem-sucedida
  static Future<void> _logSuccessfulAttempt(String pin) async {
    await _ensureInitialized();
    await _auditBox.add({
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'successful_login',
      'pin_masked': '*' * pin.length,
    });
  }

  // Registar eventos de segurança
  static Future<void> _logSecurityEvent(String event) async {
    await _ensureInitialized();
    await _auditBox.add({
      'timestamp': DateTime.now().toIso8601String(),
      'event': 'security_event',
      'details': event,
    });
  }

  // Limpar tentativas antigas (mais de 1 hora)
  static Future<void> _cleanupOldAttempts() async {
    try {
      final oneHourAgo = DateTime.now().subtract(Duration(hours: 1));
      final keysToRemove = <dynamic>[];
      
      for (final entry in _auditBox.toMap().entries) {
        if (entry.value is Map && entry.value['timestamp'] is String) {
          final timestamp = DateTime.parse(entry.value['timestamp']);
          if (timestamp.isBefore(oneHourAgo)) {
            keysToRemove.add(entry.key);
          }
        }
      }
      
      for (final key in keysToRemove) {
        await _auditBox.delete(key);
      }
    } catch (e) {
      // Ignorar erros de limpeza
    }
  }

  // Obter histórico de auditoria (últimas N entradas)
  static Future<List<Map<String, dynamic>>> getAuditLog({int limit = 50}) async {
    try {
      await _ensureInitialized();
      final allLogs = _auditBox.values.toList().cast<Map<String, dynamic>>();
      return allLogs.reversed.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Obter número de tentativas falhadas
  static Future<int> getFailedAttemptsCount() async {
    await _ensureInitialized();
    return (_authBox.get('failed_attempts') as int?) ?? 0;
  }

  // Resetar tentativas falhadas (para testes ou admin reset)
  static Future<void> resetFailedAttempts() async {
    await _ensureInitialized();
    await _authBox.put('failed_attempts', 0);
    await _logSecurityEvent('Failed attempts counter reset');
  }

  // Exportar dados de auditoria com encriptação
  static Future<String> exportAuditLogEncrypted(String encryptionPassword) async {
    try {
      final logs = await getAuditLog(limit: 1000);
      final jsonData = jsonEncode(logs);
      return EncryptionService.encrypt(jsonData, encryptionPassword);
    } catch (e) {
      throw Exception('Falha ao exportar log de auditoria: $e');
    }
  }

  // Limpar log de auditoria
  static Future<void> clearAuditLog() async {
    await _ensureInitialized();
    await _auditBox.clear();
    await _logSecurityEvent('Audit log cleared');
  }
}
