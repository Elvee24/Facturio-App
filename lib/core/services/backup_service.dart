import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';

import '../../features/clientes/data/models/cliente_model.dart';
import '../../features/faturas/data/models/fatura_model.dart';
import '../../features/produtos/data/models/produto_model.dart';
import '../models/configuracao_empresa.dart';
import 'admin_auth_service.dart';
import 'encryption_service.dart';
import 'storage_service.dart';

class BackupResultado {
  final int clientes;
  final int produtos;
  final int faturas;

  const BackupResultado({
    required this.clientes,
    required this.produtos,
    required this.faturas,
  });
}

class ExportacaoResultado {
  final bool sucesso;
  final String caminhoFicheiro;
  final String mensagem;

  const ExportacaoResultado({
    required this.sucesso,
    required this.caminhoFicheiro,
    required this.mensagem,
  });
}

/// Metadados de segurança do backup
class MetadadosSeguranca {
  final String versao;
  final DateTime timestamp;
  final String appVersion;
  final String algoritmo;
  final String checksumConteudo;
  
  MetadadosSeguranca({
    required this.versao,
    required this.timestamp,
    required this.appVersion,
    required this.algoritmo,
    required this.checksumConteudo,
  });

  Map<String, dynamic> toJson() => {
    'versao': versao,
    'timestamp': timestamp.toIso8601String(),
    'appVersion': appVersion,
    'algoritmo': algoritmo,
    'checksum': checksumConteudo,
  };
}

class BackupService {
  static Future<String?> Function()? _directoryPickerOverride;
  static const List<String> _backupExtensions = ['json', 'backup', 'bak'];

  static void setDirectoryPickerOverride(
    Future<String?> Function()? picker,
  ) {
    _directoryPickerOverride = picker;
  }

  /// Obter o diretório de backup
  /// Se não foi definido pelo utilizador, usa o padrão
  static String obterDiretorioBackup(String? diretorioConfiguracao) {
    if (diretorioConfiguracao != null && diretorioConfiguracao.isNotEmpty) {
      return diretorioConfiguracao;
    }
    return getBackupDirectoryPath();
  }

  /// Permitir utilizador escolher/mudar o diretório de backup
  static Future<String?> selecionarDiretorioBackup() async {
    if (_directoryPickerOverride != null) {
      return _directoryPickerOverride!();
    }

    try {
      final diretorio = await FilePicker.platform.getDirectoryPath();
      return diretorio;
    } catch (e) {
      throw Exception('Erro ao selecionar diretório de backup: $e');
    }
  }

  static String getBackupDirectoryPath() {
    if (kIsWeb) return '';
    if (Platform.isLinux || Platform.isMacOS) {
      final homeDir = Platform.environment['HOME'] ?? '/root';
      return '$homeDir/Downloads';
    }

    if (Platform.isWindows) {
      final userName = Platform.environment['USERNAME'] ?? 'user';
      return 'C:\\Users\\$userName\\Downloads';
    }

    return Directory.systemTemp.path;
  }

  static Future<bool> abrirPastaBackups(String? diretorioConfiguracao) async {
    if (kIsWeb) return false;
    final caminhoBackup = obterDiretorioBackup(diretorioConfiguracao);
    final pasta = Directory(caminhoBackup);
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    if (Platform.isLinux) {
      final result = await Process.run('xdg-open', [pasta.path]);
      return result.exitCode == 0;
    }

    if (Platform.isWindows) {
      final result = await Process.run('explorer', [pasta.path]);
      return result.exitCode == 0;
    }

    if (Platform.isMacOS) {
      final result = await Process.run('open', [pasta.path]);
      return result.exitCode == 0;
    }

    return false;
  }


  /// Exporta os dados principais (clientes, produtos e faturas) para um ficheiro JSON
  /// com suporte para múltiplas plataformas (Linux, Windows, iOS, Android).
  static Future<ExportacaoResultado> exportarDadosAplicacao(
    StorageService storage,
  ) async {
    try {
      if (kIsWeb) return await _exportarParaWeb(storage);

      // Obter configuração da empresa
      final config = await storage.getConfiguracaoEmpresa();
      
      // Se for a primeira vez (diretório não definido), deixar utilizador escolher
      String? diretorioBackup = config.diretorioBackup;
      if (diretorioBackup == null || diretorioBackup.isEmpty) {
        final diretorioEscolhido = await selecionarDiretorioBackup();
        if (diretorioEscolhido == null || diretorioEscolhido.isEmpty) {
          return ExportacaoResultado(
            sucesso: false,
            caminhoFicheiro: '',
            mensagem: 'Nenhum diretório foi selecionado para guardar backups.',
          );
        }
        
        diretorioBackup = diretorioEscolhido;
        
        // Guardar a escolha na configuração
        final configAtualizada = config.copyWith(diretorioBackup: diretorioEscolhido);
        await storage.saveConfiguracaoEmpresa(configAtualizada);
      }

      final ficheiro = await criarFicheiroBackup(storage);
      
      if (Platform.isLinux || Platform.isMacOS) {
        return await _exportarEmUnix(ficheiro, diretorioBackup);
      } else if (Platform.isWindows) {
        return await _exportarEmWindows(ficheiro, diretorioBackup);
      } else {
        return await _exportarComShare(ficheiro);
      }
    } catch (e) {
      return ExportacaoResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar dados: $e',
      );
    }
  }

  /// Exportação específica para Linux/macOS: salva no diretório escolhido
  static Future<ExportacaoResultado> _exportarEmUnix(File ficheiro, String diretorioBackup) async {
    try {
      final downloadsDir = Directory(diretorioBackup);
      
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final nome = 'Facturio_backup_${DateTime.now().toIso8601String().split('.')[0].replaceAll(':', '-')}.backup';
      final novoFicheiro = File('${downloadsDir.path}/$nome');
      
      await ficheiro.copy(novoFicheiro.path);
      
      // Definir permissões restritivas (600: apenas proprietário pode ler/escrever)
      await Process.run('chmod', ['600', novoFicheiro.path]);
      
      return ExportacaoResultado(
        sucesso: true,
        caminhoFicheiro: novoFicheiro.path,
        mensagem: 'Backup exportado com sucesso para: ${downloadsDir.path}',
      );
    } catch (e) {
      return ExportacaoResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar no Linux/macOS: $e',
      );
    }
  }

  /// Exportação específica para Windows
  static Future<ExportacaoResultado> _exportarEmWindows(File ficheiro, String diretorioBackup) async {
    try {
      final downloadsDir = Directory(diretorioBackup);
      
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final nome = 'Facturio_backup_${DateTime.now().toIso8601String().split('.')[0].replaceAll(':', '-')}.backup';
      final novoFicheiro = File('${downloadsDir.path}\\$nome');
      
      await ficheiro.copy(novoFicheiro.path);
      
      return ExportacaoResultado(
        sucesso: true,
        caminhoFicheiro: novoFicheiro.path,
        mensagem: 'Backup exportado com sucesso para: ${downloadsDir.path}',
      );
    } catch (e) {
      return ExportacaoResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar no Windows: $e',
      );
    }
  }

  /// Exportação com Share (iOS, Android)
  static Future<ExportacaoResultado> _exportarComShare(File ficheiro) async {
    try {
      await Share.shareXFiles(
        [XFile(ficheiro.path)],
        text: 'Backup do Facturio. Guarde este ficheiro em segurança (Drive, cloud ou PC).',
        subject: 'Backup Facturio',
      );
      
      return ExportacaoResultado(
        sucesso: true,
        caminhoFicheiro: ficheiro.path,
        mensagem: 'Backup compartilhado com sucesso.',
      );
    } catch (e) {
      return ExportacaoResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao compartilhar backup: $e',
      );
    }
  }

  /// Exportação para Web: gera bytes em memória e dispara download via Share
  static Future<ExportacaoResultado> _exportarParaWeb(StorageService storage) async {
    try {
      final clientes = await storage.getClientes();
      final produtos = await storage.getProdutos();
      final faturas = await storage.getFaturas();
      final configEmpresa = await storage.getConfiguracaoEmpresa();

      final conteudo = {
        'versao': 2,
        'geradoEm': DateTime.now().toIso8601String(),
        'clientes': clientes.map((c) => c.toJson()).toList(),
        'produtos': produtos.map((p) => p.toJson()).toList(),
        'faturas': faturas.map((f) => f.toJson()).toList(),
        'configEmpresa': configEmpresa.toJson(),
      };

      final conteudoJson = const JsonEncoder().convert(conteudo);
      final checksumConteudo = sha256.convert(utf8.encode(conteudoJson)).toString();
      final conteudoEncriptado = EncryptionService.encrypt(conteudoJson, AdminAuthService.defaultPin);

      final backupSeguro = {
        'seguranca': {
          'versao': '2.0',
          'timestamp': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
          'algoritmo': 'AES-XOR-HMAC-SHA256',
          'checksum': checksumConteudo,
        },
        'conteudo_encriptado': conteudoEncriptado,
      };

      final nomeBackup = 'Facturio_backup_'
          '${DateTime.now().toIso8601String().split(".")[0].replaceAll(":", "-")}'
          '.backup';
      final bytes = Uint8List.fromList(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(backupSeguro)),
      );

      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'application/octet-stream', name: nomeBackup)],
        subject: 'Backup Facturio',
        text: 'Backup do Facturio. Guarde este ficheiro em segurança.',
      );

      return ExportacaoResultado(
        sucesso: true,
        caminhoFicheiro: nomeBackup,
        mensagem: 'Backup gerado e descarregado com sucesso.',
      );
    } catch (e) {
      return ExportacaoResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar backup para a web: $e',
      );
    }
  }
  /// Importa dados de um ficheiro JSON selecionado pelo utilizador e substitui
  /// os dados atuais de clientes, produtos e faturas.
  static Future<BackupResultado?> importarDadosAplicacao(StorageService storage) async {
    return selecionarERestaurar(storage);
  }

  static Future<File> criarFicheiroBackup(StorageService storage) async {
    final clientes = await storage.getClientes();
    final produtos = await storage.getProdutos();
    final faturas = await storage.getFaturas();
    final configEmpresa = await storage.getConfiguracaoEmpresa();

    // 1. Criar payload de conteúdo
    final conteudo = {
      'versao': 2,
      'geradoEm': DateTime.now().toIso8601String(),
      'clientes': clientes.map((c) => c.toJson()).toList(),
      'produtos': produtos.map((p) => p.toJson()).toList(),
      'faturas': faturas.map((f) => f.toJson()).toList(),
      'configEmpresa': configEmpresa.toJson(),
    };

    // 2. Serializar conteúdo e calcular checksum
    final conteudoJson = const JsonEncoder().convert(conteudo);
    final checksumConteudo = sha256.convert(utf8.encode(conteudoJson)).toString();

    // 3. Encriptar conteúdo usando PIN de admin (default: "1234")
    final pinPadrao = AdminAuthService.defaultPin;
    String conteudoEncriptado;
    try {
      conteudoEncriptado = EncryptionService.encrypt(conteudoJson, pinPadrao);
    } catch (e) {
      throw Exception('Falha ao encriptar o backup: $e');
    }

    // 4. Criar metadados de segurança
    final metadados = MetadadosSeguranca(
      versao: '2.0',
      timestamp: DateTime.now(),
      appVersion: '1.0.0',
      algoritmo: 'AES-XOR-HMAC-SHA256',
      checksumConteudo: checksumConteudo,
    );

    // 5. Criar ficheiro final com estrutura de segurança
    final backupSeguro = {
      'seguranca': {
        'versao': metadados.versao,
        'timestamp': metadados.timestamp.toIso8601String(),
        'appVersion': metadados.appVersion,
        'algoritmo': metadados.algoritmo,
        'checksum': metadados.checksumConteudo,
      },
      'conteudo_encriptado': conteudoEncriptado,
    };

    final nome = 'facturio_backup_${DateTime.now().millisecondsSinceEpoch}.backup';
    final ficheiro = File('${Directory.systemTemp.path}/$nome');
    await ficheiro.writeAsString(const JsonEncoder.withIndent('  ').convert(backupSeguro));
    
    return ficheiro;
  }


  static Future<BackupResultado?> selecionarERestaurar(StorageService storage) async {
    FilePickerResult? resultadoPicker;
    try {
      resultadoPicker = await FilePicker.platform.pickFiles(
        type: _usaSeletorGenericoNoMobile() ? FileType.any : FileType.custom,
        allowedExtensions: _usaSeletorGenericoNoMobile() ? null : _backupExtensions,
        allowMultiple: false,
        withData: true,
        withReadStream: true,
      );
    } catch (e) {
      if (Platform.isLinux && e.toString().toLowerCase().contains('zenity')) {
        final fallbackPath = await _obterBackupMaisRecenteEmDownloads();
        if (fallbackPath != null) {
          return restaurarFicheiro(storage, fallbackPath);
        }
        throw Exception(
          'O seletor de ficheiros no Linux requer o pacote zenity. '
          'Instale com: sudo apt install zenity',
        );
      }
      rethrow;
    }

    final ficheiro = resultadoPicker?.files.single;
    if (ficheiro == null) {
      return null;
    }

    if (!_ficheiroPareceBackupValido(ficheiro)) {
      throw Exception(
        'Selecione um ficheiro de backup com extensão .backup, .bak ou .json.',
      );
    }

    // Web: processar bytes em memória sem ficheiro temporário
    if (kIsWeb) {
      final bytes = ficheiro.bytes;
      if (bytes == null || bytes.isEmpty) return null;
      return _restaurarDoConteudo(storage, utf8.decode(bytes, allowMalformed: true));
    }

    final pathMaterializado = await _materializarFicheiroSelecionado(ficheiro);
    return restaurarFicheiro(storage, pathMaterializado);
  }

  static bool _usaSeletorGenericoNoMobile() {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid || Platform.isIOS;
  }

  static bool _ficheiroPareceBackupValido(PlatformFile ficheiro) {
    final candidatos = <String>[
      ficheiro.extension ?? '',
      _extrairExtensao(ficheiro.name),
      _extrairExtensao(ficheiro.path),
    ];

    return candidatos.any(
      (extensao) => _backupExtensions.contains(extensao.toLowerCase()),
    );
  }

  static String _extrairExtensao(String? valor) {
    if (valor == null || valor.isEmpty) {
      return '';
    }

    final nome = valor.split('/').last.split('\\').last;
    final indice = nome.lastIndexOf('.');
    if (indice < 0 || indice == nome.length - 1) {
      return '';
    }

    return nome.substring(indice + 1);
  }

  static Future<String?> _obterBackupMaisRecenteEmDownloads() async {
    final dir = Directory(getBackupDirectoryPath());
    if (!await dir.exists()) return null;

    final candidatos = <File>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final nome = entity.path.toLowerCase();
      if (nome.endsWith('.json') || nome.endsWith('.backup') || nome.endsWith('.bak')) {
        candidatos.add(entity);
      }
    }

    if (candidatos.isEmpty) return null;

    candidatos.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return candidatos.first.path;
  }

  static Future<String> _materializarFicheiroSelecionado(PlatformFile ficheiro) async {
    final path = ficheiro.path;
    if (path != null && path.isNotEmpty) {
      if (path.startsWith('file://')) {
        final filePath = Uri.parse(path).toFilePath();
        if (await File(filePath).exists()) return filePath;
      }

      if (await File(path).exists()) {
        return path;
      }
    }

    final bytesDiretos = ficheiro.bytes;
    if (bytesDiretos != null && bytesDiretos.isNotEmpty) {
      return _guardarBytesTemporarios(ficheiro.name, bytesDiretos);
    }

    final stream = ficheiro.readStream;
    if (stream != null) {
      final acumulado = BytesBuilder(copy: false);
      await for (final chunk in stream) {
        acumulado.add(chunk);
      }
      final bytesStream = acumulado.takeBytes();
      if (bytesStream.isNotEmpty) {
        return _guardarBytesTemporarios(ficheiro.name, bytesStream);
      }
    }

    throw Exception(
      'Não foi possível ler o ficheiro selecionado no file picker. '
      'Nome: ${ficheiro.name}, tamanho: ${ficheiro.size} bytes.',
    );
  }

  static Future<String> _guardarBytesTemporarios(String nomeOriginal, Uint8List bytes) async {
    if (kIsWeb) throw UnsupportedError('Ficheiros temporários não disponíveis na web.');
    final nomeSeguro = (nomeOriginal.isNotEmpty ? nomeOriginal : 'backup_importado.json')
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final tempFile = File('${Directory.systemTemp.path}/$nomeSeguro');
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile.path;
  }

  static Future<BackupResultado> restaurarFicheiro(StorageService storage, String path) async {
    final ficheiro = File(path);
    if (!await ficheiro.exists()) {
      throw Exception('O ficheiro de backup não foi encontrado.');
    }
    final bytes = await ficheiro.readAsBytes();
    return _restaurarDoConteudo(storage, utf8.decode(bytes, allowMalformed: true));
  }

  static Future<BackupResultado> _restaurarDoConteudo(StorageService storage, String conteudo) async {
    final json = jsonDecode(conteudo);
    if (json is! Map) {
      throw Exception('Formato de backup inválido.');
    }

    final data = Map<String, dynamic>.from(json);

    // 1. Verificar se é backup seguro (v2) ou antigo (v1)
    String conteudoJson;
    
    if (data.containsKey('seguranca') && data.containsKey('conteudo_encriptado')) {
      // Backup v2 (encriptado) - com fallback para backups criados antes da correção do bug
      try {
        conteudoJson = await _desencriptarEValidarBackup(data);
      } catch (e) {
        // Fallback: tentar importar o campo 'conteudo_encriptado' como JSON direto
        // (backups criados com versão bugada da encriptação)
        final conteudoRaw = data['conteudo_encriptado']?.toString() ?? '';
        if (_pareceJsonValido(conteudoRaw)) {
          conteudoJson = conteudoRaw;
        } else {
          rethrow;
        }
      }
    } else {
      // Backup v1 (legado, sem encriptação)
      conteudoJson = const JsonEncoder().convert(data);
    }

    // 2. Parsear conteúdo
    final conteudoParsado = jsonDecode(conteudoJson);
    if (conteudoParsado is! Map) {
      throw Exception('Formato de conteúdo de backup inválido.');
    }
    
    final dataParsada = Map<String, dynamic>.from(conteudoParsado);

    // 3. Extrair dados com validação de tipos
    final clientesJson = (dataParsada['clientes'] as List?) ?? const [];
    final produtosJson = (dataParsada['produtos'] as List?) ?? const [];
    final faturasJson = (dataParsada['faturas'] as List?) ?? const [];
    final configEmpresa = dataParsada['configEmpresa'];

    // 4. Validar estrutura antes de importar
    _validarEstruturaDados(clientesJson, produtosJson, faturasJson, configEmpresa);

    // 5. Limpar e importar dados
    await storage.clearAll();

    for (final item in clientesJson.whereType<Map>()) {
      try {
        await storage.saveCliente(ClienteModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        throw Exception('Erro ao importar cliente: $e');
      }
    }

    for (final item in produtosJson.whereType<Map>()) {
      try {
        await storage.saveProduto(ProdutoModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        throw Exception('Erro ao importar produto: $e');
      }
    }

    for (final item in faturasJson.whereType<Map>()) {
      try {
        await storage.saveFatura(FaturaModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        throw Exception('Erro ao importar fatura: $e');
      }
    }

    if (configEmpresa is Map) {
      try {
        await storage.saveConfiguracaoEmpresa(
          ConfiguracaoEmpresa.fromJson(Map<String, dynamic>.from(configEmpresa)),
        );
      } catch (e) {
        throw Exception('Erro ao importar configuração: $e');
      }
    }

    return BackupResultado(
      clientes: clientesJson.length,
      produtos: produtosJson.length,
      faturas: faturasJson.length,
    );
  }

  /// Verificar se uma string parece ser JSON válido
  static bool _pareceJsonValido(String s) {
    final t = s.trim();
    return (t.startsWith('{') && t.endsWith('}')) ||
           (t.startsWith('[') && t.endsWith(']'));
  }

  /// Desencriptar e validar integridade de backup encriptado (v2)
  static Future<String> _desencriptarEValidarBackup(Map<String, dynamic> data) async {
    try {
      // 1. Extrair metadados de segurança
      final seguranca = data['seguranca'];
      if (seguranca is! Map) {
        throw Exception('Metadados de segurança ausentes.');
      }
      
      final metadata = Map<String, dynamic>.from(seguranca);
      final checksumEsperado = metadata['checksum'];
      final conteudoEncriptado = data['conteudo_encriptado'] as String?;
      
      if (checksumEsperado == null || conteudoEncriptado == null) {
        throw Exception('Estrutura de backup encriptado inválida.');
      }

      // 2. Desencriptar com PIN padrão
      String conteudoDesencriptado;
      try {
        final pinPadrao = AdminAuthService.defaultPin;
        conteudoDesencriptado = EncryptionService.decrypt(conteudoEncriptado, pinPadrao);
      } catch (e) {
        throw Exception(
          'Falha ao desencriptar o backup. '
          'O PIN pode ter sido alterado desde que o backup foi criado. '
          'Erro: $e',
        );
      }

      // 3. Validar integridade com checksum SHA256
      final checksumCalculado = sha256.convert(utf8.encode(conteudoDesencriptado)).toString();
      
      if (checksumCalculado != checksumEsperado) {
        throw Exception(
          'Falha na validação de integridade do backup. '
          'O ficheiro pode ter sido corrompido ou modificado. '
          'Checksum esperado: $checksumEsperado, calculado: $checksumCalculado',
        );
      }

      return conteudoDesencriptado;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao desencriptar backup: $e');
    }
  }

  /// Validar estrutura de dados do backup
  static void _validarEstruturaDados(
    List<dynamic> clientes,
    List<dynamic> produtos,
    List<dynamic> faturas,
    dynamic configEmpresa,
  ) {
    // Validar que configEmpresa é um mapa se não for nulo
    if (configEmpresa != null && configEmpresa is! Map) {
      throw Exception('Campo "configEmpresa" não é um mapa válido.');
    }

    // Validar que não há dados suspeitos
    final todosDados = [...clientes, ...produtos, ...faturas];
    if (todosDados.isEmpty && configEmpresa == null) {
      throw Exception('Backup vazio: nenhum dado para importar.');
    }

    // Verificar tamanho razoável (proteção contra DoS)
    if (clientes.length > 100000) {
      throw Exception('Número de clientes suspeito (> 100.000).');
    }
    if (produtos.length > 100000) {
      throw Exception('Número de produtos suspeito (> 100.000).');
    }
    if (faturas.length > 100000) {
      throw Exception('Número de faturas suspeito (> 100.000).');
    }
  }
}

