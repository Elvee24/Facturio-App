import '../constants/app_constants.dart';
import '../services/admin_auth_service.dart';

class ConfiguracaoEmpresa {
  // Dados básicos da empresa
  final String nomeEmpresa;
  final String nif; // Número de Identificação Fiscal (obrigatório)
  final String morada; // Morada completa (obrigatório)
  final String codigoPostal; // Código postal (obrigatório)
  final String localidade; // Localidade/Cidade (obrigatório)
  final String pais; // País (obrigatório)
  
  // Dados adicionais legais
  final String? email; // Email da empresa
  final String? telefone; // Telefone da empresa
  final String? cae; // Classificação de Atividades Económicas
  final String? capitalSocial; // Capital social (para sociedades)
  final String? conservatoria; // Conservatória do Registo Comercial
  final String? numeroRegistoComercial; // Número de matrícula
  
  // Certificação AT (Autoridade Tributária e Aduaneira)
  final String? numeroChaveCertificacaoAT; // Chave de certificação AT
  final String? codigoValidacaoSoftwareAT; // Código de validação do software
  
  // Configurações de faturação
  final List<double> ivaOptions;
  final List<String> unidades;
  final List<String> estadosFatura;
  final List<String> meiosPagamento; // Novos meios de pagamento
  final List<String> tiposDocumento; // Fatura, Fatura Simplificada, etc.
  final String serieAtual; // Série de documentos atual
  
  // Configurações de backup
  final String? diretorioBackup; // Diretório de backup escolhido pelo utilizador
  
  // Segurança
  final String adminPinHash;

  const ConfiguracaoEmpresa({
    required this.nomeEmpresa,
    required this.nif,
    required this.morada,
    required this.codigoPostal,
    required this.localidade,
    required this.pais,
    this.email,
    this.telefone,
    this.cae,
    this.capitalSocial,
    this.conservatoria,
    this.numeroRegistoComercial,
    this.numeroChaveCertificacaoAT,
    this.codigoValidacaoSoftwareAT,
    required this.ivaOptions,
    required this.unidades,
    required this.estadosFatura,
    required this.meiosPagamento,
    required this.tiposDocumento,
    required this.serieAtual,
    this.diretorioBackup,
    required this.adminPinHash,
  });

  factory ConfiguracaoEmpresa.padrao() {
    return const ConfiguracaoEmpresa(
      nomeEmpresa: AppConstants.appName,
      nif: '999999990', // NIF de exemplo - DEVE SER ALTERADO
      morada: 'Rua Exemplo, nº 123',
      codigoPostal: '1000-001',
      localidade: 'Lisboa',
      pais: 'Portugal',
      email: 'exemplo@empresa.pt',
      telefone: '+351 210 000 000',
      cae: '62020', // Exemplo: Atividades de consultoria
      capitalSocial: null,
      conservatoria: null,
      numeroRegistoComercial: null,
      numeroChaveCertificacaoAT: null,
      codigoValidacaoSoftwareAT: null,
      ivaOptions: AppConstants.ivaOptions,
      unidades: AppConstants.unidades,
      estadosFatura: AppConstants.estadosFatura,
      meiosPagamento: AppConstants.meiosPagamento,
      tiposDocumento: AppConstants.tiposDocumento,
      serieAtual: 'A',
      diretorioBackup: null,
      adminPinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
    );
  }

  ConfiguracaoEmpresa copyWith({
    String? nomeEmpresa,
    String? nif,
    String? morada,
    String? codigoPostal,
    String? localidade,
    String? pais,
    String? email,
    String? telefone,
    String? cae,
    String? capitalSocial,
    String? conservatoria,
    String? numeroRegistoComercial,
    String? numeroChaveCertificacaoAT,
    String? codigoValidacaoSoftwareAT,
    List<double>? ivaOptions,
    List<String>? unidades,
    List<String>? estadosFatura,
    List<String>? meiosPagamento,
    List<String>? tiposDocumento,
    String? serieAtual,
    String? diretorioBackup,
    String? adminPinHash,
  }) {
    return ConfiguracaoEmpresa(
      nomeEmpresa: nomeEmpresa ?? this.nomeEmpresa,
      nif: nif ?? this.nif,
      morada: morada ?? this.morada,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      localidade: localidade ?? this.localidade,
      pais: pais ?? this.pais,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cae: cae ?? this.cae,
      capitalSocial: capitalSocial ?? this.capitalSocial,
      conservatoria: conservatoria ?? this.conservatoria,
      numeroRegistoComercial: numeroRegistoComercial ?? this.numeroRegistoComercial,
      numeroChaveCertificacaoAT: numeroChaveCertificacaoAT ?? this.numeroChaveCertificacaoAT,
      codigoValidacaoSoftwareAT: codigoValidacaoSoftwareAT ?? this.codigoValidacaoSoftwareAT,
      ivaOptions: ivaOptions ?? this.ivaOptions,
      unidades: unidades ?? this.unidades,
      estadosFatura: estadosFatura ?? this.estadosFatura,
      meiosPagamento: meiosPagamento ?? this.meiosPagamento,
      tiposDocumento: tiposDocumento ?? this.tiposDocumento,
      serieAtual: serieAtual ?? this.serieAtual,
      diretorioBackup: diretorioBackup ?? this.diretorioBackup,
      adminPinHash: adminPinHash ?? this.adminPinHash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeEmpresa': nomeEmpresa,
      'nif': nif,
      'morada': morada,
      'codigoPostal': codigoPostal,
      'localidade': localidade,
      'pais': pais,
      'email': email,
      'telefone': telefone,
      'cae': cae,
      'capitalSocial': capitalSocial,
      'conservatoria': conservatoria,
      'numeroRegistoComercial': numeroRegistoComercial,
      'numeroChaveCertificacaoAT': numeroChaveCertificacaoAT,
      'codigoValidacaoSoftwareAT': codigoValidacaoSoftwareAT,
      'ivaOptions': ivaOptions,
      'unidades': unidades,
      'estadosFatura': estadosFatura,
      'meiosPagamento': meiosPagamento,
      'tiposDocumento': tiposDocumento,
      'serieAtual': serieAtual,
      'diretorioBackup': diretorioBackup,
      'adminPinHash': adminPinHash,
    };
  }

  factory ConfiguracaoEmpresa.fromJson(Map<String, dynamic> json) {
    final ivaRaw = (json['ivaOptions'] as List?) ?? AppConstants.ivaOptions;
    final unidadesRaw = (json['unidades'] as List?) ?? AppConstants.unidades;
    final estadosRaw = (json['estadosFatura'] as List?) ?? AppConstants.estadosFatura;
    final meiosRaw = (json['meiosPagamento'] as List?) ?? AppConstants.meiosPagamento;
    final tiposRaw = (json['tiposDocumento'] as List?) ?? AppConstants.tiposDocumento;

    final ivaOptions = ivaRaw
        .map((e) => (e as num).toDouble())
        .toSet()
        .toList()
      ..sort();
    final unidades = unidadesRaw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    final estadosFatura = estadosRaw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    final meiosPagamento = meiosRaw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    final tiposDocumento = tiposRaw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return ConfiguracaoEmpresa(
      nomeEmpresa: (json['nomeEmpresa'] as String?)?.trim().isNotEmpty == true
          ? (json['nomeEmpresa'] as String)
          : AppConstants.appName,
      nif: (json['nif'] as String?)?.trim() ?? '999999990',
      morada: (json['morada'] as String?)?.trim() ?? 'Rua Exemplo, nº 123',
      codigoPostal: (json['codigoPostal'] as String?)?.trim() ?? '1000-001',
      localidade: (json['localidade'] as String?)?.trim() ?? 'Lisboa',
      pais: (json['pais'] as String?)?.trim() ?? 'Portugal',
      email: (json['email'] as String?)?.trim(),
      telefone: (json['telefone'] as String?)?.trim(),
      cae: (json['cae'] as String?)?.trim(),
      capitalSocial: (json['capitalSocial'] as String?)?.trim(),
      conservatoria: (json['conservatoria'] as String?)?.trim(),
      numeroRegistoComercial: (json['numeroRegistoComercial'] as String?)?.trim(),
      numeroChaveCertificacaoAT: (json['numeroChaveCertificacaoAT'] as String?)?.trim(),
      codigoValidacaoSoftwareAT: (json['codigoValidacaoSoftwareAT'] as String?)?.trim(),
      ivaOptions: ivaOptions.isEmpty ? [...AppConstants.ivaOptions] : ivaOptions,
      unidades: unidades.isEmpty ? [...AppConstants.unidades] : unidades,
      estadosFatura:
          estadosFatura.isEmpty ? [...AppConstants.estadosFatura] : estadosFatura,
      meiosPagamento:
          meiosPagamento.isEmpty ? [...AppConstants.meiosPagamento] : meiosPagamento,
      tiposDocumento:
          tiposDocumento.isEmpty ? [...AppConstants.tiposDocumento] : tiposDocumento,
      serieAtual: (json['serieAtual'] as String?)?.trim() ?? 'A',
      diretorioBackup: (json['diretorioBackup'] as String?)?.trim(),
      adminPinHash: (json['adminPinHash'] as String?)?.trim().isNotEmpty == true
          ? (json['adminPinHash'] as String)
          : AdminAuthService.defaultPinHash,
    );
  }
}
