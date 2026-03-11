import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';

/// Serviço de proteção contra reverse engineering e debugging
class AntiDebuggingService {
  static bool _monitoringActive = false;
  
  // Verificar se está em modo debug
  static bool isDebugMode() {
    // Verificação via reflection (pode falhar em algumas plataformas)
    try {
      return _checkDebuggerAttached();
    } catch (e) {
      return false;
    }
  }

  // Verificar se há debugger anexado (método simplificado)
  static bool _checkDebuggerAttached() {
    // Verificar variáveis de ambiente
    final env = Platform.environment;
    
    if (env.containsKey('DEBUG') ||
        env.containsKey('FLUTTER_DEBUG') ||
        env.containsKey('DART_VM_OPTIONS') ||
        env.containsKey('LD_PRELOAD')) {
      return true;
    }

    // Verificar ficheiros de sistema que indicam debug
    if (Platform.isLinux || Platform.isMacOS) {
      try {
        for (final processName in ['gdb', 'lldb']) {
          final result = Process.runSync('pidof', [processName], runInShell: false);
          if (result.exitCode == 0) {
            return true;
          }
        }
        return false;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  // Verificar se está em emulador
  static Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      try {
        final result = await Process.run('getprop', ['ro.kernel.qemu']);
        return result.stdout.toString().contains('1');
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Verificar se há ferramenta de debug instalada
  static Future<bool> hasDebugTools() async {
    if (Platform.isLinux || Platform.isMacOS) {
      final debugTools = ['gdb', 'lldb', 'strace', 'ltrace'];
      
      for (final tool in debugTools) {
        try {
          final result = Process.runSync('which', [tool], runInShell: false);
          if (result.exitCode == 0) {
            return true;
          }
        } catch (e) {
          // Ignorar
        }
      }
    }
    return false;
  }

  // Detectar modificação de ficheiros executáveis
  static Future<bool> detectFileModification(String filePath) async {
    if (kIsWeb) return false;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      // Obter tamanho e data de modificação
      final stat = await file.stat();
      
      // Se modificado nos últimos 5 minutos, é suspeito
      final modificationAge = DateTime.now().difference(stat.modified);
      return modificationAge.inMinutes < 5;
    } catch (e) {
      return false;
    }
  }

  // Obstruir stack trace (ofuscar informações de stack)
  static String obscureStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    final obscuredLines = lines
        .where((line) => !line.contains('lib/') && !line.contains('package:'))
        .toList();
    return obscuredLines.join('\n');
  }

  // Implementar anti-tampering simples
  static Future<Map<String, String>> calculateAppSignature(
    List<String> criticalFiles,
  ) async {
    if (kIsWeb) return {};
    final signatures = <String, String>{};

    for (final filePath in criticalFiles) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          final content = await file.readAsBytes();
          signatures[filePath] = sha256.convert(content).toString();
        }
      } catch (e) {
        // Ignorar arquivos não acessíveis
      }
    }

    return signatures;
  }

  // Verificar integridade da app
  static Future<bool> verifyAppIntegrity(
    Map<String, String> expectedSignatures,
    List<String> criticalFiles,
  ) async {
    if (kIsWeb) return false;
    try {
      final currentSignatures = await calculateAppSignature(criticalFiles);

      for (final entry in expectedSignatures.entries) {
        if (!currentSignatures.containsKey(entry.key)) {
          // Arquivo desapareceu
          return false;
        }

        if (currentSignatures[entry.key] != entry.value) {
          // Arquivo foi modificado
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Monitorar acesso ao debugger em tempo real
  static Future<void> monitorDebuggerAccess(
    Function() onDebuggerDetected,
  ) async {
    if (_monitoringActive) return;
    _monitoringActive = true;

    unawaited(_monitorLoop(onDebuggerDetected));
  }

  static Future<void> _monitorLoop(Function() onDebuggerDetected) async {
    while (_monitoringActive) {
      await Future.delayed(const Duration(seconds: 10));
      if (isDebugMode() || await isEmulator()) {
        await onDebuggerDetected();
      }
    }
  }

  static void stopMonitoringDebuggerAccess() {
    _monitoringActive = false;
  }

  // Proteger dados sensíveis da memória (ofuscar)
  static String obfuscateSensitiveData(String data) {
    if (data.length < 4) return '****';
    
    final visible = data.substring(0, 2);
    final hidden = '*' * (data.length - 4);
    final end = data.substring(data.length - 2);
    
    return visible + hidden + end;
  }

  // Validar integridade da string de versão (anti-patch)
  static bool verifyVersionIntegrity(String version, String expectedVersion) {
    return version == expectedVersion;
  }

  // Implementar timeout de sessão contra debugging prolongado
  static bool validateSessionTimeout(
    DateTime lastActivityTime,
    Duration timeoutDuration,
  ) {
    final elapsed = DateTime.now().difference(lastActivityTime);
    return elapsed < timeoutDuration;
  }
}
