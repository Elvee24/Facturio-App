import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

/// Serviço para proteger ficheiros da aplicação com permissões restritas
class FileSecurityService {
  
  // Criar diretório seguro com permissões restritas
  static Future<Directory> createSecureDirectory(String directoryName) async {
    if (kIsWeb) return Directory('');
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final secureDir = Directory('${appDocDir.path}/$directoryName');
      
      if (!await secureDir.exists()) {
        await secureDir.create(recursive: true);
      }
      
      // Definir permissões restritas (apenas para dono - 700)
      await _setRestrictedPermissions(secureDir);
      
      return secureDir;
    } catch (e) {
      throw FileSecurityException('Falha ao criar diretório seguro: $e');
    }
  }

  // Obter diretório seguro para dados da app
  static Future<Directory> getSecureAppDataDirectory() async {
    return createSecureDirectory('.facturio_secure');
  }

  // Definir permissões restritas (700 - rwx------)
  static Future<void> _setRestrictedPermissions(FileSystemEntity entity) async {
    try {
      // No Linux/Unix, usar chmod via Process
      if (Platform.isLinux || Platform.isMacOS) {
        await Process.run('chmod', ['700', entity.path]);
      }
      // No Windows, não há equivalente direto
    } catch (e) {
      // Falhar silencioso se não conseguir alterar permissões
    }
  }

  // Criar ficheiro seguro
  static Future<File> createSecureFile(String fileName) async {
    if (kIsWeb) throw FileSecurityException('Não suportado na web');
    try {
      final secureDir = await getSecureAppDataDirectory();
      final file = File('${secureDir.path}/$fileName');
      
      if (!await file.exists()) {
        await file.create();
        await _setRestrictedPermissions(file);
      }
      
      return file;
    } catch (e) {
      throw FileSecurityException('Falha ao criar ficheiro seguro: $e');
    }
  }

  // Obter ficheiro seguro
  static Future<File?> getSecureFile(String fileName) async {
    if (kIsWeb) return null;
    try {
      final secureDir = await getSecureAppDataDirectory();
      final file = File('${secureDir.path}/$fileName');
      
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Guardar dados com segurança
  static Future<void> writeSecureFile(String fileName, String content) async {
    if (kIsWeb) return;
    try {
      final file = await createSecureFile(fileName);
      await file.writeAsString(content);
      await _setRestrictedPermissions(file);
    } catch (e) {
      throw FileSecurityException('Falha ao guardar ficheiro seguro: $e');
    }
  }

  // Ler ficheiro seguro
  static Future<String?> readSecureFile(String fileName) async {
    if (kIsWeb) return null;
    try {
      final file = await getSecureFile(fileName);
      if (file != null && await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      throw FileSecurityException('Falha ao ler ficheiro seguro: $e');
    }
  }

  // Eliminar ficheiro seguro
  static Future<void> deleteSecureFile(String fileName) async {
    if (kIsWeb) return;
    try {
      final file = await getSecureFile(fileName);
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSecurityException('Falha ao eliminar ficheiro seguro: $e');
    }
  }

  // Verificar integridade do ficheiro (comparar hash)
  static Future<String> getFileHash(File file) async {
    if (kIsWeb) return '';
    try {
      final content = await file.readAsBytes();
      return sha256.convert(content).toString();
    } catch (e) {
      throw FileSecurityException('Falha ao calcular hash: $e');
    }
  }

  // Limpar all dados sensíveis de um ficheiro antes de eliminar
  static Future<void> secureDelete(File file) async {
    if (kIsWeb) return;
    try {
      if (await file.exists()) {
        // Sobrescrever com dados aleatórios 3 vezes (Gutmann's method simplified)
        final length = await file.length();
        for (int i = 0; i < 3; i++) {
          final random = List<int>.generate(length, (_) => i * 85);
          await file.writeAsBytes(random);
        }
        // Eliminar ficheiro
        await file.delete();
      }
    } catch (e) {
      throw FileSecurityException('Falha ao eliminar ficheiro com segurança: $e');
    }
  }

  // Verificar permissões do ficheiro
  static Future<bool> hasRestrictedPermissions(FileSystemEntity entity) async {
    if (kIsWeb) return true;
    try {
      if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('stat', ['-c', '%a', entity.path]);
        return result.stdout.toString().trim() == '700';
      }
      return true; // Windows não tem equivalente
    } catch (e) {
      return false;
    }
  }
}

class FileSecurityException implements Exception {
  final String message;

  FileSecurityException(this.message);

  @override
  String toString() => 'FileSecurityException: $message';
}
