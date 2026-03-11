import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Serviço de verificação de integridade de dados para detectar manipulação
class IntegrityCheckService {
  
  // Gerar checksum HMAC para dados
  static String generateChecksum(String data, String secretKey) {
    try {
      final hmac = Hmac(sha256, utf8.encode(secretKey));
      final checksum = hmac.convert(utf8.encode(data)).toString();
      return checksum;
    } catch (e) {
      throw IntegrityException('Falha ao gerar checksum: $e');
    }
  }

  // Verificar integridade de dados
  static bool verifyChecksum(String data, String checksum, String secretKey) {
    try {
      final calculated = generateChecksum(data, secretKey);
      return _constantTimeEquals(calculated, checksum);
    } catch (e) {
      return false;
    }
  }

  // Gerar assinatura digital (Merkle-like) para estrutura de dados
  static String generateDataSignature(Map<String, dynamic> data, String secretKey) {
    try {
      // Ordenar chaves para garantir consistência
      final sortedKeys = data.keys.toList()..sort();
      final sortedMap = {for (var k in sortedKeys) k: data[k]};
      
      final jsonString = jsonEncode(sortedMap);
      return generateChecksum(jsonString, secretKey);
    } catch (e) {
      throw IntegrityException('Falha ao gerar assinatura: $e');
    }
  }

  // Verificar assinatura de dados
  static bool verifyDataSignature(
    Map<String, dynamic> data,
    String signature,
    String secretKey,
  ) {
    try {
      final calculated = generateDataSignature(data, secretKey);
      return _constantTimeEquals(calculated, signature);
    } catch (e) {
      return false;
    }
  }

  // Gerar árvore de hash (Merkle tree simplificada) para listas
  static String generateMerkleRoot(List<String> dataItems, String secretKey) {
    try {
      if (dataItems.isEmpty) {
        return generateChecksum('', secretKey);
      }

      var hashes = <String>[];
      for (final item in dataItems) {
        hashes.add(generateChecksum(item, secretKey));
      }

      while (hashes.length > 1) {
        var nextLevel = <String>[];
        for (int i = 0; i < hashes.length; i += 2) {
          final left = hashes[i];
          final right = i + 1 < hashes.length ? hashes[i + 1] : hashes[i];
          final combined = left + right;
          nextLevel.add(generateChecksum(combined, secretKey));
        }
        hashes = nextLevel;
      }

      return hashes.first;
    } catch (e) {
      throw IntegrityException('Falha ao gerar Merkle root: $e');
    }
  }

  // Detectar manipulação de arquivo comparando checksums
  static bool detectFileManipulation(
    String fileContent,
    String originalChecksum,
    String secretKey,
  ) {
    final currentChecksum = generateChecksum(fileContent, secretKey);
    return !_constantTimeEquals(currentChecksum, originalChecksum);
  }

  // Gerar checksum para configuração completa da app
  static String generateAppConfigChecksum(
    Map<String, dynamic> config,
    String secretKey,
  ) {
    try {
      final criticalFields = {
        'version': config['version'],
        'security_level': config['security_level'],
        'encryption_enabled': config['encryption_enabled'],
        'auth_enabled': config['auth_enabled'],
      };
      
      return generateDataSignature(criticalFields, secretKey);
    } catch (e) {
      throw IntegrityException('Falha ao gerar checksum de config: $e');
    }
  }

  // Comparação timing-safe
  static bool _constantTimeEquals(String a, String b) {
    int result = a.length ^ b.length;
    for (int i = 0; i < a.length && i < b.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // Gerar hash para detecção de mudanças
  static String generateChangeDetectionHash(
    Map<String, dynamic> beforeState,
    Map<String, dynamic> afterState,
  ) {
    try {
      final diff = _generateDiff(beforeState, afterState);
      return sha256.convert(utf8.encode(jsonEncode(diff))).toString();
    } catch (e) {
      throw IntegrityException('Falha ao gerar hash de mudança: $e');
    }
  }

  // Detectar mudanças não autorizadas
  static List<String> detectUnauthorizedChanges(
    Map<String, dynamic> expectedState,
    Map<String, dynamic> actualState,
  ) {
    final changes = <String>[];

    for (final key in expectedState.keys) {
      if (!actualState.containsKey(key)) {
        changes.add('Campo removido: $key');
      } else if (expectedState[key] != actualState[key]) {
        changes.add('Campo alterado: $key (esperado: ${expectedState[key]}, obtido: ${actualState[key]})');
      }
    }

    for (final key in actualState.keys) {
      if (!expectedState.containsKey(key)) {
        changes.add('Campo adicionado: $key');
      }
    }

    return changes;
  }

  // Gerar diferenças entre dois objetos
  static Map<String, dynamic> _generateDiff(
    Map<String, dynamic> before,
    Map<String, dynamic> after,
  ) {
    final diff = <String, dynamic>{};

    for (final key in before.keys) {
      if (!after.containsKey(key)) {
        diff['removed_$key'] = before[key];
      } else if (before[key] != after[key]) {
        diff['changed_$key'] = {
          'old': before[key],
          'new': after[key],
        };
      }
    }

    for (final key in after.keys) {
      if (!before.containsKey(key)) {
        diff['added_$key'] = after[key];
      }
    }

    return diff;
  }
}

class IntegrityException implements Exception {
  final String message;

  IntegrityException(this.message);

  @override
  String toString() => 'IntegrityException: $message';
}
