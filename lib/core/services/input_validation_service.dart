/// Serviço de validação rigorosa de entrada contra injeção e exploração
class InputValidationService {
  
  // Padrões perigosos que indicam possíveis ataques
  static final RegExp _sqlInjectionPattern = RegExp(
    r"('|(--)|(/\*)|(;\s*DROP)|(\bOR\b|\bAND\b)(?=.*('|$)))",
    caseSensitive: false,
  );
  
  static final RegExp _pathTraversalPattern = RegExp(
    r"(\.\./|\.\.\\|%2e%2e|\.\.%2f|\.\.%5c)",
    caseSensitive: false,
  );
  
  static final RegExp _scriptInjectionPattern = RegExp(
    r"(<script|javascript:|onerror=|onload=|onclick=|<iframe|eval\()",
    caseSensitive: false,
  );
  
  static final RegExp _commandInjectionPattern = RegExp(
    r"([;|&`$(){}[\]<>]|bash|sh|cmd|cmd\.exe|powershell)",
    caseSensitive: false,
  );

  // Extensões perigosas
  static const List<String> dangerousExtensions = [
    '.exe', '.bat', '.cmd', '.scr', '.vbs', '.js', '.jar', '.zip',
    '.dll', '.so', '.dylib', '.app', '.apk', '.dex', '.elf',
  ];

  // Validar NIF (Portugal)
  static bool isValidNIF(String nif) {
    if (nif.length != 9 || !RegExp(r'^\d{9}$').hasMatch(nif)) {
      return false;
    }
    
    final digits = nif.split('').map(int.parse).toList();
    int sum = 0;
    for (int i = 0; i < 8; i++) {
      sum += digits[i] * (10 - i - 1);
    }
    final checkDigit = (11 - (sum % 11)) % 11;
    return checkDigit == digits[8] || (checkDigit == 10 && digits[8] == 0);
  }

  // Validar email com rigor
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    
    if (!emailRegex.hasMatch(email)) return false;
    if (email.length > 254) return false;
    if (email.startsWith('.') || email.endsWith('.')) return false;
    
    return true;
  }

  // Validar IBAN (Portugal)
  static bool isValidIBAN(String iban) {
    iban = iban.toUpperCase().replaceAll(' ', '');
    
    if (!RegExp(r'^PT\d{2}\d{4}\d{4}[\dA-Z]{11}$').hasMatch(iban)) {
      return false;
    }
    
    // Validar checksum IBAN
    final rearranged = iban.substring(4) + iban.substring(0, 4);
    final numeric = rearranged.replaceAllMapped(RegExp('[A-Z]'), (m) {
      return (m.group(0)!.codeUnitAt(0) - 55).toString();
    });
    
    return _modElevem(numeric) == 1;
  }

  // Calcular MOD 97-10 para IBAN
  static int _modElevem(String numeric) {
    int remainder = 0;
    for (final digit in numeric.split('')) {
      remainder = (remainder * 10 + int.parse(digit)) % 97;
    }
    return remainder;
  }

  // Validar entrada de texto contra injeção
  static ValidationResult validateTextInput(
    String input, {
    required int minLength,
    required int maxLength,
    bool allowSpecialChars = false,
  }) {
    if (input.isEmpty) {
      return ValidationResult(false, 'Input não pode ser vazio');
    }

    if (input.length < minLength || input.length > maxLength) {
      return ValidationResult(false, 'Input deve ter entre $minLength e $maxLength caracteres');
    }

    // Verificar SQL injection
    if (_sqlInjectionPattern.hasMatch(input)) {
      return ValidationResult(false, 'Input contém padrões suspeitos (SQL injection)');
    }

    // Verificar script injection
    if (_scriptInjectionPattern.hasMatch(input)) {
      return ValidationResult(false, 'Input contém padrões suspeitos (script injection)');
    }

    // Verificar command injection
    if (_commandInjectionPattern.hasMatch(input)) {
      return ValidationResult(false, 'Input contém padrões suspeitos (command injection)');
    }

    // Validar caracteres
    if (!allowSpecialChars) {
      if (!RegExp(r'^[a-zA-Z0-9áéíóúàâêôãõçÁÉÍÓÚÀÂÊÔÃÕÇ\s\-_.]*$').hasMatch(input)) {
        return ValidationResult(false, 'Input contém caracteres não permitidos');
      }
    }

    return ValidationResult(true, 'Validação OK');
  }

  // Validar número (quantidade, preço, etc)
  static ValidationResult validateNumber(
    String input, {
    required double minValue,
    required double maxValue,
    int decimalPlaces = 2,
  }) {
    try {
      final number = double.parse(input);
      
      if (number < minValue || number > maxValue) {
        return ValidationResult(false, 'Número deve estar entre $minValue e $maxValue');
      }
      
      final regex = RegExp(r'^\d+(\.\d{1,' + decimalPlaces.toString() + r'})?$');
      if (!regex.hasMatch(input)) {
        return ValidationResult(false, 'Número deve ter no máximo $decimalPlaces casas decimais');
      }
      
      return ValidationResult(true, 'Validação OK');
    } catch (e) {
      return ValidationResult(false, 'Entrada inválida como número');
    }
  }

  // Validar caminho de arquivo contra path traversal
  static ValidationResult validateFilePath(String path) {
    if (_pathTraversalPattern.hasMatch(path)) {
      return ValidationResult(false, 'Caminho contém padrões suspeitos (path traversal)');
    }

    final filename = path.split('/').last.split('\\').last;
    
    for (final ext in dangerousExtensions) {
      if (filename.toLowerCase().endsWith(ext)) {
        return ValidationResult(false, 'Tipo de ficheiro não permitido: $ext');
      }
    }

    return ValidationResult(true, 'Validação OK');
  }

  // Validar UUID/ID
  static bool isValidUUID(String uuid) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(uuid);
  }

  // Sanitizar entrada (remover caracteres perigosos)
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp("[<>\"'`]"), '') // Remove caracteres HTML/JS
        .replaceAll(RegExp(r'[;|&{}()[\]]'), '') // Remove caracteres shell
        .trim();
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);

  @override
  String toString() => 'Validação ${isValid ? "OK" : "FALHOU"}: $message';
}

class InputValidationException implements Exception {
  final String message;

  InputValidationException(this.message);

  @override
  String toString() => 'InputValidationException: $message';
}
