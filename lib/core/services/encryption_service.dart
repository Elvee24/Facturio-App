import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Serviço de encriptação simples e seguro para dados sensíveis
class EncryptionService {
  
  // Derivar chave a partir de uma senha usando PBKDF2 simples
  static Uint8List deriveKey(String masterPassword, {String? salt}) {
    salt ??= 'facturio_default_salt_2026';
    
    // Usar HMAC-SHA256 com iterações
    var key = utf8.encode(masterPassword);
    var saltBytes = utf8.encode(salt);
    
    for (int i = 0; i < 100000; i++) {
      final hmac = Hmac(sha256, key);
      key = Uint8List.fromList(hmac.convert(saltBytes).bytes);
      saltBytes = key;
    }
    
    return Uint8List.fromList(key.take(32).toList());
  }

  // Encriptar dados usando XOR com keystream derivado
  static String encrypt(String plaintext, String masterPassword) {
    try {
      final random = Random.secure();
      final salt = Uint8List.fromList(
        List<int>.generate(16, (i) => random.nextInt(256))
      );
      
      final key = deriveKey(masterPassword, salt: base64Encode(salt));
      final plainBytes = utf8.encode(plaintext);
      
      // Gerar keystream usando apenas salt + contador (simétrico com decrypt)
      final keyStreamBytes = _gerarKeystream(key, salt, plainBytes.length);
      
      // XOR encrypt
      final encryptedBytes = <int>[];
      for (int i = 0; i < plainBytes.length; i++) {
        encryptedBytes.add(plainBytes[i] ^ keyStreamBytes[i]);
      }
      
      // Calcular tag de autenticação
      final hmacTag = Hmac(sha256, key);
      final tagData = Uint8List.fromList([...salt, ...encryptedBytes]);
      final tag = hmacTag.convert(tagData).bytes;
      
      // Combinar: salt + tag + dados encriptados
      final combined = Uint8List(salt.length + tag.length + encryptedBytes.length);
      combined.setRange(0, salt.length, salt);
      combined.setRange(salt.length, salt.length + tag.length, tag);
      combined.setRange(salt.length + tag.length, combined.length, encryptedBytes);
      
      return base64Encode(combined);
    } catch (e) {
      throw EncryptionException('Falha ao encriptar: $e');
    }
  }

  // Gerar keystream determinístico a partir de key + salt + contador de bloco
  // NÃO depende do plaintext nem do ciphertext — garante simetria
  static List<int> _gerarKeystream(Uint8List key, Uint8List salt, int tamanhoNecessario) {
    final keyStreamBytes = <int>[];
    int block = 0;
    while (keyStreamBytes.length < tamanhoNecessario) {
      final hmac = Hmac(sha256, key);
      final blockData = Uint8List.fromList([
        ...salt,
        (block >> 24) & 0xFF,
        (block >> 16) & 0xFF,
        (block >> 8) & 0xFF,
        block & 0xFF,
      ]);
      keyStreamBytes.addAll(hmac.convert(blockData).bytes);
      block++;
    }
    return keyStreamBytes;
  }

  // Desencriptar dados
  static String decrypt(String ciphertext, String masterPassword) {
    try {
      final combined = base64Decode(ciphertext);
      
      if (combined.length < 48) {
        throw EncryptionException('Dados encriptados inválidos (tamanho)');
      }
      
      final salt = combined.sublist(0, 16);
      final tag = combined.sublist(16, 48);
      final encryptedBytes = combined.sublist(48);
      
      final key = deriveKey(masterPassword, salt: base64Encode(salt));
      
      // Verificar tag de autenticação
      final hmacVerify = Hmac(sha256, key);
      final tagData = Uint8List.fromList([...salt, ...encryptedBytes]);
      final calculatedTag = hmacVerify.convert(tagData).bytes;
      
      // Comparação timing-safe
      bool tagValid = true;
      for (int i = 0; i < tag.length && i < calculatedTag.length; i++) {
        if (tag[i] != calculatedTag[i]) {
          tagValid = false;
        }
      }
      
      if (!tagValid) {
        throw EncryptionException('Falha na verificação de integridade (tag inválida)');
      }
      
      // Desencriptar usando o mesmo keystream (salt + contador, idêntico ao encrypt)
      final keyStreamBytes = _gerarKeystream(key, salt, encryptedBytes.length);
      
      final plainBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        plainBytes.add(encryptedBytes[i] ^ keyStreamBytes[i]);
      }
      
      return utf8.decode(plainBytes);
    } catch (e) {
      if (e is EncryptionException) rethrow;
      throw EncryptionException('Falha ao desencriptar: $e');
    }
  }

  // Hash seguro com salt aleatório (para PIN/senhas) - PBKDF2
  static String hashWithSalt(String value) {
    final random = Random.secure();
    final salt = base64Encode(
      Uint8List.fromList(List<int>.generate(16, (i) => random.nextInt(256)))
    );
    
    final key = deriveKey(value, salt: salt);
    final hash = base64Encode(key);
    
    return '$salt:$hash';
  }

  // Verificar hash com salt - timing-safe comparison
  static bool verifyHash(String value, String saltedHash) {
    try {
      final parts = saltedHash.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      final storedHash = parts[1];
      
      final key = deriveKey(value, salt: salt);
      final calculatedHash = base64Encode(key);
      
      // Comparação timing-safe
      return _constantTimeEquals(calculatedHash, storedHash);
    } catch (e) {
      return false;
    }
  }

  // Comparação timing-safe para evitar timing attacks
  static bool _constantTimeEquals(String a, String b) {
    int result = a.length ^ b.length;
    for (int i = 0; i < a.length && i < b.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

class EncryptionException implements Exception {
  final String message;

  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}
