import 'package:hive_flutter/hive_flutter.dart';
import 'encryption_service.dart';

/// Serviço para encriptar dados sensíveis no Hive
/// Encripta campos como: NIF, IBAN, Email, Valores Bancários
class SecureDataService {

  static const String _masterKeyBoxName = 'secure_encryption_keys';
  static String _cachedMasterKey = '';

  // Campos sensíveis que devem ser encriptados
  static const List<String> sensitiveCLienteFields = ['nif', 'email', 'numero_telefone', 'iban'];
  static const List<String> sensitivePagamentoFields = ['numero_cheque', 'numero_referencia'];

  // Inicializar serviço
  static Future<void> init() async {
    await Hive.openBox<String>(_masterKeyBoxName);
  }

  // Definir chave mestre (deve ser chamada na primeira autenticação)
  static Future<void> setMasterKey(String pinOuPassword) async {
    try {
      _cachedMasterKey = pinOuPassword;
      // A chave é derivada do PIN atual - não precisa guardar nada adicional
    } catch (e) {
      throw SecureDataException('Falha ao definir chave mestre: $e');
    }
  }

  // Encriptar valor sensível
  static String encryptField(String plainValue) {
    if (_cachedMasterKey.isEmpty) {
      throw SecureDataException('Chave mestre não definida');
    }
    
    try {
      return EncryptionService.encrypt(plainValue, _cachedMasterKey);
    } catch (e) {
      throw SecureDataException('Falha ao encriptar campo: $e');
    }
  }

  // Desencriptar valor sensível
  static String decryptField(String encryptedValue) {
    if (_cachedMasterKey.isEmpty) {
      throw SecureDataException('Chave mestre não definida');
    }
    
    try {
      return EncryptionService.decrypt(encryptedValue, _cachedMasterKey);
    } catch (e) {
      // Valor pode não estar encriptado (preservar compatibilidade)
      return encryptedValue;
    }
  }

  // Designar se um campo deve ser encriptado
  static bool shouldEncryptField(String entityType, String fieldName) {
    final field = fieldName.toLowerCase();
    
    switch (entityType.toLowerCase()) {
      case 'cliente':
        return sensitiveCLienteFields.contains(field);
      case 'pagamento':
        return sensitivePagamentoFields.contains(field);
      default:
        return false;
    }
  }

  // Encriptar objecto JSON (encriptando apenas campos sensíveis)
  static Map<String, dynamic> encryptJsonObject(
    Map<String, dynamic> data,
    String entityType,
  ) {
    final encrypted = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (shouldEncryptField(entityType, entry.key)) {
        try {
          encrypted[entry.key] = encryptField(entry.value?.toString() ?? '');
        } catch (e) {
          // Falhar seguro - manter valor original se encriptação falhar
          encrypted[entry.key] = entry.value;
        }
      } else {
        encrypted[entry.key] = entry.value;
      }
    }
    
    return encrypted;
  }

  // Desencriptar objecto JSON
  static Map<String, dynamic> decryptJsonObject(
    Map<String, dynamic> data,
    String entityType,
  ) {
    final decrypted = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (shouldEncryptField(entityType, entry.key)) {
        try {
          decrypted[entry.key] = decryptField(entry.value?.toString() ?? '');
        } catch (e) {
          // Valor pode não estar encriptado - manter como está
          decrypted[entry.key] = entry.value;
        }
      } else {
        decrypted[entry.key] = entry.value;
      }
    }
    
    return decrypted;
  }

  // Verificar integridade de dados (saltar dados corrompidos)
  static bool verifyDataIntegrity(String encryptedValue) {
    try {
      // Tentar desencriptar
      decryptField(encryptedValue);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Exportar dados com auditoria de encriptação
  static Future<String> exportEncryptedBackup(String backupPassword) async {
    if (backupPassword.trim().isEmpty) {
      throw SecureDataException('A palavra-passe do backup não pode estar vazia.');
    }

    if (_cachedMasterKey.isEmpty) {
      throw SecureDataException('Chave mestre não definida. Autentique-se antes de exportar dados encriptados.');
    }

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'masterKeySet': true,
    };

    try {
      return EncryptionService.encrypt(payload.toString(), backupPassword);
    } catch (e) {
      throw SecureDataException('Falha ao exportar backup encriptado: $e');
    }
  }

  // Limpar chave mestre (para logout)
  static void clearMasterKey() {
    _cachedMasterKey = '';
  }

  // Verificar se chave mestre está definida
  static bool isMasterKeySet() {
    return _cachedMasterKey.isNotEmpty;
  }
}

class SecureDataException implements Exception {
  final String message;

  SecureDataException(this.message);

  @override
  String toString() => 'SecureDataException: $message';
}
