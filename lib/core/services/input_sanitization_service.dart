/// Serviço de limpeza/sanitização de entrada para remover conteúdo malicioso
class InputSanitizationService {
  
  // Caracteres HTML perigosos
  static const _htmlEntityMap = {
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '&': '&amp;',
  };

  // Remover tags HTML/JS
  static String sanitizeHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
  }

  // Codificar caracteres especiais para HTML
  static String encodeHtmlEntities(String input) {
    String result = input;
    _htmlEntityMap.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  // Decodificar caracteres HTML
  static String decodeHtmlEntities(String input) {
    String result = input;
    _htmlEntityMap.forEach((key, value) {
      result = result.replaceAll(value, key);
    });
    return result;
  }

  // Remover caracteres de controle/invisíveis
  static String removeControlCharacters(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  // Normalizar whitespace
  static String normalizeWhitespace(String input) {
    return input
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove linhas em branco múltiplas
        .replaceAll(RegExp(r'\s+'), ' ') // Colapsa espaços consecutivos
        .trim();
  }

  // Sanitização geral para entrada de texto livre
  static String sanitizeInput(String input) {
    return normalizeWhitespace(
      removeControlCharacters(
        removeNullBytes(
          sanitizeHtml(input),
        ),
      ),
    );
  }

  // Escapar SQL (prevenção básica)
  static String escapeSql(String input) {
    return input
        .replaceAll("'", "''") // Double single quotes
        .replaceAll('"', '""')  // Double double quotes
        .replaceAll(RegExp(r'[;\-*/]'), ''); // Remove caracteres de comando
  }

  // Escapar JSON
  static String escapeJson(String input) {
    return input
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll('\b', '\\b')
        .replaceAll('\f', '\\f')
        .replaceAll('\\', '\\\\');
  }

  // Remover null bytes
  static String removeNullBytes(String input) {
    return input.replaceAll('\x00', '');
  }

  // Sanitização completa para nomes de ficheiros
  static String sanitizeFileName(String filename) {
    return filename
        .replaceAll(RegExp(r'[<>:"|?*]'), '_') // Windows invalid chars
        .replaceAll(RegExp(r'[\x00-\x1F]'), '') // Control chars
        .replaceAll(RegExp(r'\.{2,}'), '') // Remove ..
        .replaceAll(RegExp(r'^\.'), '') // Remove leading dot
        .trim();
  }

  // Sanitização para URLs
  static String sanitizeUrl(String url) {
    // Remover protocolos perigosos
    if (url.startsWith('javascript:') ||
        url.startsWith('data:') ||
        url.startsWith('vbscript:')) {
      return '';
    }

    return Uri.encodeFull(url);
  }

  // Sanitização para comandos de sistema (bloquear)
  static bool isSafeCommand(String command) {
    final dangerousPatterns = [
      r'rm\s+-rf',
      r'del\s+/s',
      r'format\s+',
      r'mkfs\.',
      r'dd\s+',
      r'>\s*/',
      r'>\s*\w:',
    ];

    for (final pattern in dangerousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(command)) {
        return false;
      }
    }

    return true;
  }

  // Sanitizar entrada de lista (multi-linha)
  static List<String> sanitizeList(List<String> items) {
    return items
        .map((item) => sanitizeInput(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // Sanitizar mapa completo
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> input) {
    final sanitized = <String, dynamic>{};

    input.forEach((key, value) {
      if (value is String) {
        sanitized[key] = sanitizeInput(value);
      } else if (value is List) {
        sanitized[key] = value.map((v) {
          return v is String ? sanitizeInput(v) : v;
        }).toList();
      } else if (value is Map) {
        sanitized[key] = sanitizeMap(value as Map<String, dynamic>);
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  // Validar MIME type
  static bool isValidMimeType(String mimeType, List<String> allowed) {
    return allowed.contains(mimeType.toLowerCase());
  }

  // Sanitização de entrada para JSON
  static String sanitizeJsonInput(String jsonString) {
    return removeControlCharacters(
      removeNullBytes(
        normalizeWhitespace(jsonString),
      ),
    );
  }
}
