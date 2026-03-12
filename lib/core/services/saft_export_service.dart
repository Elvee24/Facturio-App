import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';

import '../../features/clientes/data/models/cliente_model.dart';
import '../../features/faturas/data/models/fatura_model.dart';
import '../../features/produtos/data/models/produto_model.dart';
import '../../shared/models/linha_fatura.dart';
import '../../shared/models/pagamento.dart';
import '../constants/app_constants.dart';
import '../models/configuracao_empresa.dart';
import 'backup_service.dart';
import 'fatura_legal_service.dart';
import 'storage_service.dart';

class SaftPeriodo {
  final DateTime dataInicio;
  final DateTime dataFim;

  const SaftPeriodo({
    required this.dataInicio,
    required this.dataFim,
  });

  bool contem(DateTime data) {
    final inicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    final fim = DateTime(dataFim.year, dataFim.month, dataFim.day, 23, 59, 59, 999);
    return !data.isBefore(inicio) && !data.isAfter(fim);
  }
}

class SaftValidationException implements Exception {
  final String message;

  const SaftValidationException(this.message);

  @override
  String toString() => message;
}

class SaftExportResultado {
  final bool sucesso;
  final String caminhoFicheiro;
  final String mensagem;
  final int totalFaturas;

  const SaftExportResultado({
    required this.sucesso,
    required this.caminhoFicheiro,
    required this.mensagem,
    required this.totalFaturas,
  });
}

class SaftExportService {
  static const String _saftNamespace = 'urn:OECD:StandardAuditFile-Tax:PT_1.04_01';
  static const String _saftVersion = '1.04_01';
  static const String _productType = 'P';

  static Future<SaftExportResultado> exportarSaft({
    required StorageService storage,
    required SaftPeriodo periodo,
  }) async {
    try {
      final config = await storage.getConfiguracaoEmpresa();
      _validarConfiguracaoLegal(config);

      final clientes = await storage.getClientes();
      final produtos = await storage.getProdutos();
      final faturas = await storage.getFaturas();
      final pagamentos = await storage.getPagamentos();

      final faturasPeriodo = faturas
          .where((fatura) => periodo.contem(fatura.data))
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));

      if (faturasPeriodo.isEmpty) {
        return const SaftExportResultado(
          sucesso: false,
          caminhoFicheiro: '',
          mensagem: 'Nao existem faturas no periodo selecionado para exportacao SAF-T.',
          totalFaturas: 0,
        );
      }

      final xml = _gerarXmlSaft(
        config: config,
        clientes: clientes,
        produtos: produtos,
        faturas: faturasPeriodo,
        pagamentos: pagamentos,
        periodo: periodo,
      );

      if (kIsWeb) {
        return _exportarParaWeb(xml, periodo, faturasPeriodo.length);
      }

      // Em mobile (Android/iOS), o fluxo correto e partilhar diretamente o
      // ficheiro temporario. Nao deve depender de diretorio de backup.
      if (Platform.isAndroid || Platform.isIOS) {
        final ficheiro = await _criarFicheiroTemporario(xml, periodo);
        return _exportarComShare(ficheiro, faturasPeriodo.length);
      }

      String? diretorio = config.diretorioBackup;
      if (diretorio == null || diretorio.isEmpty) {
        diretorio = await BackupService.selecionarDiretorioBackup();
        if (diretorio == null || diretorio.isEmpty) {
          return const SaftExportResultado(
            sucesso: false,
            caminhoFicheiro: '',
            mensagem: 'Nenhum diretorio foi selecionado para guardar o SAF-T.',
            totalFaturas: 0,
          );
        }

        await storage.saveConfiguracaoEmpresa(
          config.copyWith(diretorioBackup: diretorio),
        );
      }

      final ficheiro = await _criarFicheiroTemporario(xml, periodo);
      if (Platform.isLinux || Platform.isMacOS) {
        return _exportarEmUnix(ficheiro, diretorio, faturasPeriodo.length);
      }
      if (Platform.isWindows) {
        return _exportarEmWindows(ficheiro, diretorio, faturasPeriodo.length);
      }
      return _exportarComShare(ficheiro, faturasPeriodo.length);
    } on SaftValidationException catch (e) {
      return SaftExportResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: e.message,
        totalFaturas: 0,
      );
    } catch (e) {
      return SaftExportResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar SAF-T: $e',
        totalFaturas: 0,
      );
    }
  }

  static void _validarConfiguracaoLegal(ConfiguracaoEmpresa config) {
    if (config.nomeEmpresa.trim().isEmpty) {
      throw const SaftValidationException('Preencha o nome da empresa antes de exportar SAF-T.');
    }
    if (!FaturaLegalService.validarNIF(config.nif.trim())) {
      throw const SaftValidationException('O NIF da empresa e obrigatorio e tem de ser valido para exportar SAF-T.');
    }
    if (config.morada.trim().isEmpty ||
        config.codigoPostal.trim().isEmpty ||
        config.localidade.trim().isEmpty ||
        config.pais.trim().isEmpty) {
      throw const SaftValidationException(
        'Preencha a morada completa da empresa antes de exportar SAF-T.',
      );
    }
  }

  static String _gerarXmlSaft({
    required ConfiguracaoEmpresa config,
    required List<ClienteModel> clientes,
    required List<ProdutoModel> produtos,
    required List<FaturaModel> faturas,
    required List<Pagamento> pagamentos,
    required SaftPeriodo periodo,
  }) {
    final customerIds = <String>{};
    final productIds = <String>{};
    final pagamentosPorFatura = <String, List<Pagamento>>{};

    for (final pagamento in pagamentos) {
      pagamentosPorFatura.putIfAbsent(pagamento.faturaId, () => []).add(pagamento);
    }

    for (final fatura in faturas) {
      customerIds.add(fatura.clienteId);
      for (final linha in fatura.linhas) {
        productIds.add(linha.produtoId);
      }
    }

    final clientesSaft = clientes
        .where((cliente) => customerIds.contains(cliente.id))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
    final produtosSaft = produtos
        .where((produto) => productIds.contains(produto.id))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));

    final totalDebit = faturas
        .where((f) => !_isNotaCredito(f.tipoDocumento))
        .fold<double>(0, (sum, f) => sum + f.total);
    final totalCredit = faturas
        .where((f) => _isNotaCredito(f.tipoDocumento))
        .fold<double>(0, (sum, f) => sum + f.total);

    final builder = StringBuffer();
    builder.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    builder.writeln('<AuditFile xmlns="$_saftNamespace">');
    builder.write(_headerXml(config, periodo));
    builder.write(_masterFilesXml(config, clientesSaft, produtosSaft));
    builder.write(
      _sourceDocumentsXml(
        faturas: faturas,
        pagamentosPorFatura: pagamentosPorFatura,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
      ),
    );
    builder.writeln('</AuditFile>');
    return builder.toString();
  }

  static String _headerXml(ConfiguracaoEmpresa config, SaftPeriodo periodo) {
    final now = DateTime.now();
    return '''
  <Header>
    <AuditFileVersion>$_saftVersion</AuditFileVersion>
    <CompanyID>${_xml(config.nif)}</CompanyID>
    <TaxRegistrationNumber>${_xml(config.nif)}</TaxRegistrationNumber>
    <TaxAccountingBasis>F</TaxAccountingBasis>
    <CompanyName>${_xml(config.nomeEmpresa)}</CompanyName>
    <BusinessName>${_xml(config.nomeEmpresa)}</BusinessName>
    <CompanyAddress>
      <AddressDetail>${_xml(config.morada)}</AddressDetail>
      <City>${_xml(config.localidade)}</City>
      <PostalCode>${_xml(config.codigoPostal)}</PostalCode>
      <Country>${_countryCode(config.pais)}</Country>
    </CompanyAddress>
    <FiscalYear>${periodo.dataInicio.year}</FiscalYear>
    <StartDate>${_date(periodo.dataInicio)}</StartDate>
    <EndDate>${_date(periodo.dataFim)}</EndDate>
    <CurrencyCode>EUR</CurrencyCode>
    <DateCreated>${_date(now)}</DateCreated>
    <TaxEntity>${_countryCode(config.pais)}</TaxEntity>
    <ProductCompanyTaxID>${_xml(config.nif)}</ProductCompanyTaxID>
    <SoftwareCertificateNumber>${_xml(config.numeroChaveCertificacaoAT ?? '0')}</SoftwareCertificateNumber>
    <ProductID>${_xml(AppConstants.appName)}</ProductID>
    <ProductVersion>${_xml(AppConstants.appVersion)}</ProductVersion>
    <Telephone>${_xml(config.telefone ?? '')}</Telephone>
    <Email>${_xml(config.email ?? '')}</Email>
  </Header>
''';
  }

  static String _masterFilesXml(
    ConfiguracaoEmpresa config,
    List<ClienteModel> clientes,
    List<ProdutoModel> produtos,
  ) {
    final builder = StringBuffer();
    builder.writeln('  <MasterFiles>');
    builder.write(_supplierXml(config));
    builder.write(_defaultCustomerXml());
    for (final cliente in clientes) {
      builder.write(_customerXml(cliente));
    }
    for (final produto in produtos) {
      builder.write(_productXml(produto));
    }
    builder.writeln('  </MasterFiles>');
    return builder.toString();
  }

  static String _supplierXml(ConfiguracaoEmpresa config) {
    return '''
    <Supplier>
      <SupplierID>${_xml(config.nif)}</SupplierID>
      <AccountID>Desconhecida</AccountID>
      <SupplierTaxID>${_xml(config.nif)}</SupplierTaxID>
      <CompanyName>${_xml(config.nomeEmpresa)}</CompanyName>
      <BillingAddress>
        <AddressDetail>${_xml(config.morada)}</AddressDetail>
        <City>${_xml(config.localidade)}</City>
        <PostalCode>${_xml(config.codigoPostal)}</PostalCode>
        <Country>${_countryCode(config.pais)}</Country>
      </BillingAddress>
      <Telephone>${_xml(config.telefone ?? '')}</Telephone>
      <Email>${_xml(config.email ?? '')}</Email>
    </Supplier>
''';
  }

  static String _defaultCustomerXml() {
    return '''
    <Customer>
      <CustomerID>ConsumidorFinal</CustomerID>
      <AccountID>Desconhecida</AccountID>
      <CustomerTaxID>999999990</CustomerTaxID>
      <CompanyName>Consumidor Final</CompanyName>
      <BillingAddress>
        <AddressDetail>Desconhecida</AddressDetail>
        <City>Desconhecida</City>
        <PostalCode>0000-000</PostalCode>
        <Country>PT</Country>
      </BillingAddress>
    </Customer>
''';
  }

  static String _customerXml(ClienteModel cliente) {
    final nifValido = FaturaLegalService.validarNIF(cliente.nif);
    return '''
    <Customer>
      <CustomerID>${_xml(cliente.id)}</CustomerID>
      <AccountID>Desconhecida</AccountID>
      <CustomerTaxID>${_xml(nifValido ? cliente.nif : '999999990')}</CustomerTaxID>
      <CompanyName>${_xml(cliente.nome)}</CompanyName>
      <BillingAddress>
        <AddressDetail>${_xml(cliente.morada.isEmpty ? 'Desconhecida' : cliente.morada)}</AddressDetail>
        <City>${_xml(_cityFromAddress(cliente.morada))}</City>
        <PostalCode>${_xml(_postalFromAddress(cliente.morada))}</PostalCode>
        <Country>PT</Country>
      </BillingAddress>
      <Telephone>${_xml(cliente.telefone)}</Telephone>
      <Email>${_xml(cliente.email)}</Email>
      <SelfBillingIndicator>0</SelfBillingIndicator>
    </Customer>
''';
  }

  static String _productXml(ProdutoModel produto) {
    return '''
    <Product>
      <ProductType>$_productType</ProductType>
      <ProductCode>${_xml(produto.id)}</ProductCode>
      <ProductGroup>${_xml(produto.unidade)}</ProductGroup>
      <ProductDescription>${_xml(produto.descricao.isEmpty ? produto.nome : produto.descricao)}</ProductDescription>
      <ProductNumberCode>${_xml(produto.nome)}</ProductNumberCode>
    </Product>
''';
  }

  static String _sourceDocumentsXml({
    required List<FaturaModel> faturas,
    required Map<String, List<Pagamento>> pagamentosPorFatura,
    required double totalCredit,
    required double totalDebit,
  }) {
    final builder = StringBuffer();
    builder.writeln('  <SourceDocuments>');
    builder.writeln('    <SalesInvoices>');
    builder.writeln('      <NumberOfEntries>${faturas.length}</NumberOfEntries>');
    builder.writeln('      <TotalDebit>${_money(totalDebit)}</TotalDebit>');
    builder.writeln('      <TotalCredit>${_money(totalCredit)}</TotalCredit>');
    for (final fatura in faturas) {
      builder.write(_invoiceXml(fatura, pagamentosPorFatura[fatura.id] ?? const []));
    }
    builder.writeln('    </SalesInvoices>');
    builder.writeln('  </SourceDocuments>');
    return builder.toString();
  }

  static String _invoiceXml(FaturaModel fatura, List<Pagamento> pagamentos) {
    final grossTotal = pagamentos.isNotEmpty
        ? pagamentos.fold<double>(0, (sum, pagamento) => sum + pagamento.valor)
        : fatura.totalComRetencao;
    final builder = StringBuffer();
    builder.writeln('      <Invoice>');
    builder.writeln('        <InvoiceNo>${_xml(fatura.numero)}</InvoiceNo>');
    builder.writeln('        <ATCUD>${_xml(fatura.codigoATCUD ?? '')}</ATCUD>');
    builder.writeln('        <DocumentStatus>');
    builder.writeln('          <InvoiceStatus>${_invoiceStatus(fatura.estado)}</InvoiceStatus>');
    builder.writeln('          <InvoiceStatusDate>${_dateTime(fatura.dataUltimaAlteracao ?? fatura.dataCriacao)}</InvoiceStatusDate>');
    builder.writeln('          <SourceID>Facturio</SourceID>');
    builder.writeln('          <SourceBilling>P</SourceBilling>');
    builder.writeln('        </DocumentStatus>');
    builder.writeln('        <Hash>${_xml(fatura.hashAnterior ?? '')}</Hash>');
    builder.writeln('        <HashControl>1</HashControl>');
    builder.writeln('        <Period>${fatura.data.month}</Period>');
    builder.writeln('        <InvoiceDate>${_date(fatura.data)}</InvoiceDate>');
    builder.writeln('        <InvoiceType>${_invoiceTypeCode(fatura.tipoDocumento)}</InvoiceType>');
    builder.writeln('        <SpecialRegimes>');
    builder.writeln('          <SelfBillingIndicator>0</SelfBillingIndicator>');
    builder.writeln('          <CashVATSchemeIndicator>0</CashVATSchemeIndicator>');
    builder.writeln('          <ThirdPartiesBillingIndicator>0</ThirdPartiesBillingIndicator>');
    builder.writeln('        </SpecialRegimes>');
    builder.writeln('        <SourceID>Facturio</SourceID>');
    builder.writeln('        <SystemEntryDate>${_dateTime(fatura.dataCriacao)}</SystemEntryDate>');
    builder.writeln('        <CustomerID>${_xml(fatura.clienteId.isEmpty ? 'ConsumidorFinal' : fatura.clienteId)}</CustomerID>');
    builder.writeln('        <DocumentTotals>');
    builder.writeln('          <TaxPayable>${_money(fatura.totalIva)}</TaxPayable>');
    builder.writeln('          <NetTotal>${_money(fatura.subtotal)}</NetTotal>');
    builder.writeln('          <GrossTotal>${_money(grossTotal)}</GrossTotal>');
    if ((fatura.valorRetencao ?? 0) > 0 && (fatura.retencaoFonte ?? 0) > 0) {
      builder.writeln('          <WithholdingTax>');
      builder.writeln('            <WithholdingTaxType>IRS</WithholdingTaxType>');
      builder.writeln('            <WithholdingTaxDescription>${_xml('Retencao na fonte')}</WithholdingTaxDescription>');
      builder.writeln('            <WithholdingTaxAmount>${_money(fatura.valorRetencao ?? 0)}</WithholdingTaxAmount>');
      builder.writeln('          </WithholdingTax>');
    }
    builder.writeln('        </DocumentTotals>');
    for (var i = 0; i < fatura.linhas.length; i++) {
      builder.write(_invoiceLineXml(fatura.linhas[i], i + 1, fatura));
    }
    if (pagamentos.isNotEmpty) {
      for (final pagamento in pagamentos) {
        builder.writeln('        <Settlement>');
        builder.writeln('          <SettlementAmount>${_money(pagamento.valor)}</SettlementAmount>');
        builder.writeln('          <SettlementDate>${_date(pagamento.dataPagamento)}</SettlementDate>');
        builder.writeln('          <PaymentMechanism>${_xml(_paymentCode(pagamento.meioPagamento))}</PaymentMechanism>');
        builder.writeln('        </Settlement>');
      }
    }
    builder.writeln('      </Invoice>');
    return builder.toString();
  }

  static String _invoiceLineXml(LinhaFatura linha, int lineNumber, FaturaModel fatura) {
    final builder = StringBuffer();
    builder.writeln('        <Line>');
    builder.writeln('          <LineNumber>$lineNumber</LineNumber>');
    builder.writeln('          <ProductCode>${_xml(linha.produtoId)}</ProductCode>');
    builder.writeln('          <ProductDescription>${_xml(linha.produtoNome)}</ProductDescription>');
    builder.writeln('          <Quantity>${_decimal(linha.quantidade, 3)}</Quantity>');
    builder.writeln('          <UnitOfMeasure>${_xml('UN')}</UnitOfMeasure>');
    builder.writeln('          <UnitPrice>${_money(linha.precoUnitario)}</UnitPrice>');
    builder.writeln('          <TaxPointDate>${_date(fatura.data)}</TaxPointDate>');
    builder.writeln('          <Description>${_xml(linha.produtoNome)}</Description>');
    builder.writeln('          <CreditAmount>${_money(linha.subtotal)}</CreditAmount>');
    if (linha.desconto > 0) {
      builder.writeln('          <SettlementAmount>${_money((linha.quantidade * linha.precoUnitario) - linha.subtotal)}</SettlementAmount>');
    }
    builder.writeln('          <Tax>');
    builder.writeln('            <TaxType>IVA</TaxType>');
    builder.writeln('            <TaxCountryRegion>PT</TaxCountryRegion>');
    builder.writeln('            <TaxCode>${_taxCode(linha.iva)}</TaxCode>');
    builder.writeln('            <TaxPercentage>${_decimal(linha.iva, 2)}</TaxPercentage>');
    if (fatura.temIsencaoIVA) {
      builder.writeln('            <TaxExemptionReason>${_xml(fatura.motivoIsencaoIVA ?? '')}</TaxExemptionReason>');
      builder.writeln('            <TaxExemptionCode>${_xml(_taxExemptionCode(fatura.motivoIsencaoIVA))}</TaxExemptionCode>');
    }
    builder.writeln('          </Tax>');
    builder.writeln('        </Line>');
    return builder.toString();
  }

  static Future<File> _criarFicheiroTemporario(String xml, SaftPeriodo periodo) async {
    final nome = _nomeFicheiro(periodo);
    final ficheiro = File('${Directory.systemTemp.path}/$nome');
    await ficheiro.writeAsString(xml, encoding: utf8);
    return ficheiro;
  }

  static Future<SaftExportResultado> _exportarEmUnix(
    File ficheiro,
    String diretorio,
    int totalFaturas,
  ) async {
    try {
      final dir = Directory(diretorio);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final destino = File('${dir.path}/${ficheiro.uri.pathSegments.last}');
      await ficheiro.copy(destino.path);
      await Process.run('chmod', ['600', destino.path]);

      return SaftExportResultado(
        sucesso: true,
        caminhoFicheiro: destino.path,
        mensagem: 'SAF-T exportado com sucesso para: ${dir.path}',
        totalFaturas: totalFaturas,
      );
    } catch (e) {
      return SaftExportResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar SAF-T no Linux/macOS: $e',
        totalFaturas: 0,
      );
    }
  }

  static Future<SaftExportResultado> _exportarEmWindows(
    File ficheiro,
    String diretorio,
    int totalFaturas,
  ) async {
    try {
      final dir = Directory(diretorio);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final destino = File('${dir.path}\\${ficheiro.uri.pathSegments.last}');
      await ficheiro.copy(destino.path);

      return SaftExportResultado(
        sucesso: true,
        caminhoFicheiro: destino.path,
        mensagem: 'SAF-T exportado com sucesso para: ${dir.path}',
        totalFaturas: totalFaturas,
      );
    } catch (e) {
      return SaftExportResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar SAF-T no Windows: $e',
        totalFaturas: 0,
      );
    }
  }

  static Future<SaftExportResultado> _exportarComShare(
    File ficheiro,
    int totalFaturas,
  ) async {
    try {
      await Share.shareXFiles(
        [XFile(ficheiro.path)],
        subject: 'Exportacao SAF-T Facturio',
        text: 'Ficheiro SAF-T do Facturio para arquivo fiscal e auditoria.',
      );

      return SaftExportResultado(
        sucesso: true,
        caminhoFicheiro: ficheiro.path,
        mensagem: 'SAF-T partilhado com sucesso.',
        totalFaturas: totalFaturas,
      );
    } catch (e) {
      return SaftExportResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao partilhar SAF-T: $e',
        totalFaturas: 0,
      );
    }
  }

  static Future<SaftExportResultado> _exportarParaWeb(
    String xml,
    SaftPeriodo periodo,
    int totalFaturas,
  ) async {
    try {
      final bytes = Uint8List.fromList(utf8.encode(xml));
      final nome = _nomeFicheiro(periodo);
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'application/xml', name: nome)],
        subject: 'Exportacao SAF-T Facturio',
        text: 'Ficheiro SAF-T do Facturio para arquivo fiscal e auditoria.',
      );

      return SaftExportResultado(
        sucesso: true,
        caminhoFicheiro: nome,
        mensagem: 'SAF-T gerado e descarregado com sucesso.',
        totalFaturas: totalFaturas,
      );
    } catch (e) {
      return SaftExportResultado(
        sucesso: false,
        caminhoFicheiro: '',
        mensagem: 'Erro ao exportar SAF-T para a web: $e',
        totalFaturas: 0,
      );
    }
  }

  static String _nomeFicheiro(SaftPeriodo periodo) {
    final inicio = DateFormat('yyyyMMdd').format(periodo.dataInicio);
    final fim = DateFormat('yyyyMMdd').format(periodo.dataFim);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'Facturio_SAFT_${inicio}_${fim}_$timestamp.xml';
  }

  static bool _isNotaCredito(String tipoDocumento) {
    return tipoDocumento.trim().toLowerCase() == AppConstants.tipoNotaCredito.toLowerCase();
  }

  static String _invoiceStatus(String estado) {
    switch (estado.trim().toLowerCase()) {
      case 'cancelada':
        return 'A';
      case 'rascunho':
        return 'N';
      default:
        return 'N';
    }
  }

  static String _invoiceTypeCode(String tipoDocumento) {
    switch (tipoDocumento.trim()) {
      case AppConstants.tipoFaturaSimplificada:
        return 'FS';
      case AppConstants.tipoFaturaRecibo:
        return 'FR';
      case AppConstants.tipoNotaCredito:
        return 'NC';
      case AppConstants.tipoNotaDebito:
        return 'ND';
      case AppConstants.tipoFatura:
      default:
        return 'FT';
    }
  }

  static String _paymentCode(String meioPagamento) {
    switch (meioPagamento.trim().toLowerCase()) {
      case 'numerario':
        return 'NU';
      case 'transferencia bancaria':
        return 'TB';
      case 'multibanco':
        return 'MB';
      case 'mb way':
        return 'OU';
      case 'debito direto':
        return 'DD';
      case 'cartao de credito':
        return 'CC';
      case 'cartao de debito':
        return 'CD';
      case 'cheque':
        return 'CH';
      default:
        return 'OU';
    }
  }

  static String _taxCode(double iva) {
    if (iva == 0) return 'ISE';
    if (iva == AppConstants.ivaReduzido) return 'RED';
    if (iva == AppConstants.ivaIntermedio) return 'INT';
    return 'NOR';
  }

  static String _taxExemptionCode(String? motivo) {
    if (motivo == null || motivo.isEmpty) return '';
    final match = RegExp(r'(M\d{2})').firstMatch(motivo);
    return match?.group(1) ?? '';
  }

  static String _countryCode(String pais) {
    final value = pais.trim().toLowerCase();
    if (value == 'portugal' || value == 'pt') {
      return 'PT';
    }
    return pais.trim().toUpperCase();
  }

  static String _postalFromAddress(String morada) {
    final match = RegExp(r'\b\d{4}-\d{3}\b').firstMatch(morada);
    return match?.group(0) ?? '0000-000';
  }

  static String _cityFromAddress(String morada) {
    final segmentos = morada
        .split(',')
        .map((segmento) => segmento.trim())
        .where((segmento) => segmento.isNotEmpty)
        .toList();
    if (segmentos.isEmpty) {
      return 'Desconhecida';
    }
    final ultima = segmentos.last;
    return ultima.length > 60 ? ultima.substring(0, 60) : ultima;
  }

  static String _xml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _date(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

  static String _dateTime(DateTime value) => DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value);

  static String _money(double value) => value.toStringAsFixed(2);

  static String _decimal(double value, int casas) => value.toStringAsFixed(casas);
}