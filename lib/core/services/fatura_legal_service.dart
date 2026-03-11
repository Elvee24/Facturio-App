import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Serviço para funcionalidades legais de faturação em Portugal
/// 
/// IMPORTANTE: Esta é uma implementação SIMULADA para fins educativos e testes.
/// Para uso EM PRODUÇÃO numa empresa REAL, é OBRIGATÓRIO:
/// 1. Certificar o software junto da AT (Autoridade Tributária e Aduaneira)
/// 2. Obter chaves de certificação AT reais
/// 3. Integrar com os webservices da AT para geração de códigos ATCUD oficiais
/// 4. Implementar o sistema de comunicação de documentos à AT
/// 
/// A não certificação do software é uma CONTRAORDENAÇÃO GRAVE segundo a lei portuguesa.
class FaturaLegalService {
  /// Gera um código ATCUD simulado
  /// 
  /// ATENÇÃO: Este código é SIMULADO e NÃO VÁLIDO para uso legal real!
  /// Em produção, deve ser obtido através da AT.
  /// 
  /// Formato ATCUD: [Código de validação AT]-[Número sequencial]
  /// Exemplo: ABCD1234-5678
  static String gerarATCUDSimulado(String serie, int numeroSequencial) {
    // SIMULAÇÃO - Em produção, isto viria da AT
    final codigoValidacao = 'SIM${serie.hashCode.abs() % 10000}';
    return '$codigoValidacao-$numeroSequencial';
  }

  /// Gera hash SHA-256 para validação de sequência de documentos
  /// 
  /// Este hash garante que os documentos não foram alterados ou eliminados
  /// e mantêm a sequência obrigatória por lei.
  static String gerarHashDocumento({
    required String numeroDocumento,
    required DateTime data,
    required double total,
    String? hashAnterior,
  }) {
    final dados = StringBuffer();
    dados.write(numeroDocumento);
    dados.write(data.toIso8601String());
    dados.write(total.toStringAsFixed(2));
    
    if (hashAnterior != null && hashAnterior.isNotEmpty) {
      dados.write(hashAnterior);
    }
    
    final bytes = utf8.encode(dados.toString());
    final hash = sha256.convert(bytes);
    
    return hash.toString().substring(0, 40); // Primeiros 40 caracteres
  }

  /// Gera dados para QR Code segundo especificações da AT
  /// 
  /// Formato: NIF Emissor*NIF Adquirente*País*Tipo Doc*Estado*Data*Nº Doc*ATCUD*Subtotal*IVA*Total*Hash
  /// 
  /// Nota: Este é o formato simplificado. O formato completo da AT pode ter mais campos.
  static String gerarDadosQRCode({
    required String nifEmissor,
    required String? nifAdquirente,
    required String tipoDocumento,
    required DateTime data,
    required String numeroDocumento,
    required String codigoATCUD,
    required double subtotal,
    required double totalIVA,
    required double total,
    String pais = 'PT',
  }) {
    final buffer = StringBuffer();
    
    buffer.write(nifEmissor);
    buffer.write('*');
    buffer.write(nifAdquirente ?? '999999990');
    buffer.write('*');
    buffer.write(pais);
    buffer.write('*');
    buffer.write(_getTipoDocumentoCode(tipoDocumento));
    buffer.write('*');
    buffer.write('N'); // N = Normal, A = Anulado
    buffer.write('*');
    buffer.write(_formatarData(data));
    buffer.write('*');
    buffer.write(numeroDocumento);
    buffer.write('*');
    buffer.write(codigoATCUD);
    buffer.write('*');
    buffer.write(subtotal.toStringAsFixed(2));
    buffer.write('*');
    buffer.write(totalIVA.toStringAsFixed(2));
    buffer.write('*');
    buffer.write(total.toStringAsFixed(2));
    
    return buffer.toString();
  }

  /// Obtém o código do tipo de documento para o QR Code
  static String _getTipoDocumentoCode(String tipoDocumento) {
    switch (tipoDocumento) {
      case 'Fatura':
        return 'FT';
      case 'Fatura Simplificada':
        return 'FS';
      case 'Fatura-Recibo':
        return 'FR';
      case 'Nota de Crédito':
        return 'NC';
      case 'Nota de Débito':
        return 'ND';
      default:
        return 'FT';
    }
  }

  /// Formata data para o QR Code (YYYYMMDD)
  static String _formatarData(DateTime data) {
    return '${data.year}${data.month.toString().padLeft(2, '0')}${data.day.toString().padLeft(2, '0')}';
  }

  /// Gera o próximo número de documento na série
  /// 
  /// Formato: SERIE ANO/NUMERO
  /// Exemplos: A 2024/1, A 2024/2, B 2024/1
  static String gerarNumeroDocumento({
    required String serie,
    required int ano,
    required int numeroSequencial,
  }) {
    return '$serie $ano/$numeroSequencial';
  }

  /// Extrai o número sequencial de um número de documento
  /// Retorna null se o formato for inválido
  static int? extrairNumeroSequencial(String numeroDocumento) {
    try {
      // Formato esperado: "SERIE ANO/NUMERO"
      final partes = numeroDocumento.split('/');
      if (partes.length == 2) {
        return int.tryParse(partes[1]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Valida se um NIF português é válido
  /// 
  /// Verifica:
  /// - Tem 9 dígitos
  /// - Primeiro dígito é válido (1, 2, 3, 5, 6, 7, 8, 9)
  /// - Dígito de controlo está correto
  static bool validarNIF(String nif) {
    if (nif.length != 9) return false;
    
    final primeiroDigito = int.tryParse(nif[0]);
    if (primeiroDigito == null) return false;
    
    // Primeiros dígitos válidos
    if (![1, 2, 3, 5, 6, 7, 8, 9].contains(primeiroDigito)) {
      return false;
    }
    
    // Calcular dígito de controlo
    int soma = 0;
    for (int i = 0; i < 8; i++) {
      final digito = int.tryParse(nif[i]);
      if (digito == null) return false;
      soma += digito * (9 - i);
    }
    
    final resto = soma % 11;
    final digitoControlo = resto < 2 ? 0 : 11 - resto;
    
    final ultimoDigito = int.tryParse(nif[8]);
    return ultimoDigito == digitoControlo;
  }

  /// Calcula o valor da retenção na fonte
  /// 
  /// Taxa padrão de retenção (para prestação de serviços): 25%
  /// Outros casos podem ter taxas diferentes
  static double calcularRetencao({
    required double valorBase,
    required double taxaRetencao, // Percentagem (ex: 25.0 para 25%)
  }) {
    return valorBase * (taxaRetencao / 100);
  }

  /// Valida código postal português (XXXX-XXX)
  static bool validarCodigoPostal(String codigoPostal) {
    final regex = RegExp(r'^\d{4}-\d{3}$');
    return regex.hasMatch(codigoPostal);
  }

  /// Valida endereço de email segundo RFC 5321/5322
  ///
  /// Verifica:
  /// - Estrutura local@domain
  /// - Comprimento máximo de 254 caracteres (RFC 5321)
  /// - Parte local até 64 caracteres
  /// - Domínio com pelo menos um ponto e TLD de 2+ letras
  static bool validarEmail(String email) {
    if (email.isEmpty) return false;
    if (email.length > 254) return false;

    final parts = email.split('@');
    if (parts.length != 2) return false;

    final local = parts[0];
    final domain = parts[1];

    if (local.isEmpty || local.length > 64) return false;
    if (domain.isEmpty) return false;

    // Local: alfanumérico + caracteres permitidos
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(local)) {
      return false;
    }
    if (local.startsWith('.') || local.endsWith('.') || local.contains('..')) {
      return false;
    }

    // Domínio: labels separados por pontos, TLD >= 2 letras
    final domainParts = domain.split('.');
    if (domainParts.length < 2) return false;
    for (final part in domainParts) {
      if (part.isEmpty || part.length > 63) return false;
      if (!RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$').hasMatch(part)) {
        return false;
      }
    }
    // TLD deve ter pelo menos 2 letras
    final tld = domainParts.last;
    if (!RegExp(r'^[a-zA-Z]{2,}$').hasMatch(tld)) return false;

    return true;
  }

  /// Valida número de telefone português
  ///
  /// Formatos aceites:
  /// - Móvel: 9[1236]XXXXXXX (91, 92, 93, 96)
  /// - Fixo: 2XXXXXXXXX (começa por 2)
  /// - Empresas: 3XXXXXXXXX (começa por 3)
  /// - Prefixo internacional +351 ou 00351 opcional
  /// - Espaços e hífenes são ignorados
  static bool validarTelefone(String telefone) {
    if (telefone.isEmpty) return false;

    // Remover espaços, hífenes e parênteses
    var limpo = telefone.replaceAll(RegExp(r'[\s\-().+]'), '');

    // Remover prefixo internacional português
    if (limpo.startsWith('00351')) {
      limpo = limpo.substring(5);
    } else if (limpo.startsWith('351') && limpo.length == 12) {
      limpo = limpo.substring(3);
    }

    if (limpo.length != 9) return false;
    if (!RegExp(r'^\d{9}$').hasMatch(limpo)) return false;

    // Validar prefixos conhecidos
    final prefixo2 = int.tryParse(limpo.substring(0, 2)) ?? -1;
    final primeiroDigito = limpo[0];

    switch (primeiroDigito) {
      case '9': // Móvel
        return [91, 92, 93, 96].contains(prefixo2);
      case '2': // Fixo
        return true;
      case '3': // Empresas / serviços
        return true;
      default:
        return false;
    }
  }

  /// Valida Código de Atividade Económica (CAE)
  ///
  /// O CAE é um código numérico de 5 dígitos segundo a Classificação Portuguesa
  /// de Atividades Económicas (CAE-Rev.3), DL 381/2007.
  static bool validarCAE(String cae) {
    final limpo = cae.trim();
    if (!RegExp(r'^\d{5}$').hasMatch(limpo)) return false;

    final valor = int.tryParse(limpo);
    if (valor == null) return false;

    // CAE válidos: 01110 a 99000 (intervalos da CAE-Rev.3)
    return valor >= 100 && valor <= 99999;
  }

  /// Valida IBAN português
  ///
  /// Formato: PT50 XXXX XXXX XXXX XXXX XXXX X (25 caracteres sem espaços)
  /// Verificação pelo algoritmo MOD 97-10 (ISO 13616)
  static bool validarIBAN(String iban) {
    // Remover espaços
    final limpo = iban.toUpperCase().replaceAll(' ', '');

    // IBAN PT: PT + 2 check digits + 21 dígitos = 25 chars
    if (!RegExp(r'^PT\d{23}$').hasMatch(limpo)) return false;

    // Algoritmo MOD 97-10: mover primeiros 4 chars para o fim, converter letras
    final rearranged = limpo.substring(4) + limpo.substring(0, 4);
    final numerico = rearranged.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => (m.group(0)!.codeUnitAt(0) - 55).toString(),
    );

    // Calcular MOD 97 com aritmética em partes (evitar overflow)
    int resto = 0;
    for (final char in numerico.split('')) {
      resto = (resto * 10 + int.parse(char)) % 97;
    }
    return resto == 1;
  }

  /// Resultado de validação com mensagem de erro legível
  static ({bool valido, String? erro}) validarEmailComMensagem(String email, {bool obrigatorio = false}) {
    if (email.isEmpty) {
      if (obrigatorio) return (valido: false, erro: 'Email é obrigatório.');
      return (valido: true, erro: null);
    }
    if (!validarEmail(email)) {
      return (valido: false, erro: 'Email inválido. Verifique o formato (ex: nome@empresa.pt).');
    }
    return (valido: true, erro: null);
  }

  /// Resultado de validação de telefone com mensagem de erro
  static ({bool valido, String? erro}) validarTelefoneComMensagem(String telefone, {bool obrigatorio = false}) {
    if (telefone.isEmpty) {
      if (obrigatorio) return (valido: false, erro: 'Telefone é obrigatório.');
      return (valido: true, erro: null);
    }
    if (!validarTelefone(telefone)) {
      return (valido: false, erro: 'Telefone inválido. Use formato português (ex: 912345678 ou +351912345678).');
    }
    return (valido: true, erro: null);
  }

  /// Resultado de validação de CAE com mensagem de erro
  static ({bool valido, String? erro}) validarCAEComMensagem(String cae, {bool obrigatorio = false}) {
    if (cae.isEmpty) {
      if (obrigatorio) return (valido: false, erro: 'CAE é obrigatório.');
      return (valido: true, erro: null);
    }
    if (!validarCAE(cae)) {
      return (valido: false, erro: 'CAE inválido. Deve ter 5 dígitos (ex: 62020).');
    }
    return (valido: true, erro: null);
  }
}
