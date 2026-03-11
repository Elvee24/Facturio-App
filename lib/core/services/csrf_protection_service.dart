import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Serviço de proteção contra CSRF (Cross-Site Request Forgery)
class CsrfProtectionService {
  
  static late Box<String> _tokenBox;
  static const String _tokenBoxName = 'csrf_tokens';
  static const int _tokenExpirationMinutes = 60;

  // Inicializar serviço
  static Future<void> init() async {
    _tokenBox = await Hive.openBox<String>(_tokenBoxName);
  }

  // Gerar token CSRF
  static Future<String> generateToken(String userId) async {
    try {
      const uuid = Uuid();
      final token = uuid.v4();
      
      // Guardar com timestamp para expiração
      await _tokenBox.put(
        token,
        '$userId:${DateTime.now().millisecondsSinceEpoch}',
      );

      // Agendar limpeza
      _scheduleTokenCleanup(token);

      return token;
    } catch (e) {
      throw CsrfException('Falha ao gerar token CSRF: $e');
    }
  }

  // Validar token CSRF
  static Future<bool> validateToken(String token, String userId) async {
    try {
      if (!_tokenBox.containsKey(token)) {
        return false;
      }

      final tokenData = _tokenBox.get(token)!.split(':');
      if (tokenData.length != 2) {
        return false;
      }

      final storedUserId = tokenData[0];
      final timestamp = int.tryParse(tokenData[1]) ?? 0;
      
      // Verificar utilizador
      if (storedUserId != userId) {
        return false;
      }

      // Verificar expiração
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > (_tokenExpirationMinutes * 60 * 1000)) {
        await _tokenBox.delete(token);
        return false;
      }

      // Consumir token (one-time use)
      await _tokenBox.delete(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Agendar limpeza de token expirado
  static void _scheduleTokenCleanup(String token) {
    Future.delayed(
      Duration(minutes: _tokenExpirationMinutes + 5),
      () {
        _tokenBox.delete(token).catchError((_) {});
      },
    );
  }

  // Limpar todos os tokens de um utilizador
  static Future<void> invalidateUserTokens(String userId) async {
    try {
      final keysToDelete = <String>[];
      
      for (final entry in _tokenBox.toMap().entries) {
        final tokenData = entry.value.split(':');
        if (tokenData.isNotEmpty && tokenData[0] == userId) {
          keysToDelete.add(entry.key as String);
        }
      }

      for (final key in keysToDelete) {
        await _tokenBox.delete(key);
      }
    } catch (e) {
      // Falhar silencioso
    }
  }

  // Limpar tokens antigos
  static Future<void> cleanupExpiredTokens() async {
    try {
      final keysToDelete = <String>[];
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final entry in _tokenBox.toMap().entries) {
        final tokenData = entry.value.split(':');
        if (tokenData.length == 2) {
          final timestamp = int.tryParse(tokenData[1]) ?? 0;
          final age = now - timestamp;
          
          if (age > (_tokenExpirationMinutes * 60 * 1000)) {
            keysToDelete.add(entry.key as String);
          }
        }
      }

      for (final key in keysToDelete) {
        await _tokenBox.delete(key);
      }
    } catch (e) {
      // Falhar silencioso
    }
  }
}

/// Serviço de proteção contra SameSite attacks
class SameSiteProtectionService {
  
  // Verificar se requisição é de mesma origem
  static bool isSameOrigin(
    String requestOrigin,
    String expectedOrigin,
  ) {
    return requestOrigin.toLowerCase() == expectedOrigin.toLowerCase();
  }

  // Validar referrer
  static bool isValidReferrer(
    String? referrer,
    String expectedOrigin,
  ) {
    if (referrer == null || referrer.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse(referrer);
      return uri.origin == expectedOrigin;
    } catch (e) {
      return false;
    }
  }

  // Implementar SameSite attribute
  static const sameSiteAttribute = 'SameSite=Strict';
  
  // Gerar headers de segurança
  static Map<String, String> getSecurityHeaders(String origin) {
    return {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy': "default-src 'self'; script-src 'self'",
      'Origin': origin,
    };
  }
}

class CsrfException implements Exception {
  final String message;

  CsrfException(this.message);

  @override
  String toString() => 'CsrfException: $message';
}
