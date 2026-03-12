import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:facturio/core/models/configuracao_empresa.dart';
import 'package:facturio/core/services/backup_service.dart';
import 'package:facturio/core/services/saft_export_service.dart';
import 'package:facturio/core/services/storage_service.dart';
import 'package:facturio/features/clientes/data/models/cliente_model.dart';
import 'package:facturio/features/faturas/data/models/fatura_model.dart';
import 'package:facturio/features/produtos/data/models/produto_model.dart';
import 'package:facturio/shared/models/linha_fatura.dart';
import 'package:facturio/shared/models/pagamento.dart';

// Reutiliza o mesmo FakeStorageService que o teste de backup já usa.
class FakeStorageService extends StorageService {
  final List<ClienteModel> _clientes = [];
  final List<ProdutoModel> _produtos = [];
  final List<FaturaModel> _faturas = [];
  ConfiguracaoEmpresa _config = ConfiguracaoEmpresa.padrao();

  @override
  Future<List<ClienteModel>> getClientes() async => List.of(_clientes);

  @override
  Future<List<ProdutoModel>> getProdutos() async => List.of(_produtos);

  @override
  Future<List<FaturaModel>> getFaturas() async => List.of(_faturas);

  @override
  Future<ConfiguracaoEmpresa> getConfiguracaoEmpresa() async => _config;

  @override
  Future<void> saveCliente(ClienteModel cliente) async {
    _clientes.removeWhere((c) => c.id == cliente.id);
    _clientes.add(cliente);
  }

  @override
  Future<void> saveProduto(ProdutoModel produto) async {
    _produtos.removeWhere((p) => p.id == produto.id);
    _produtos.add(produto);
  }

  @override
  Future<void> saveFatura(FaturaModel fatura) async {
    _faturas.removeWhere((f) => f.id == fatura.id);
    _faturas.add(fatura);
  }

  @override
  Future<void> saveConfiguracaoEmpresa(ConfiguracaoEmpresa config) async {
    _config = config;
  }

  @override
  Future<List<Pagamento>> getPagamentos() async => const [];

  @override
  Future<void> clearAll() async {
    _clientes.clear();
    _produtos.clear();
    _faturas.clear();
  }
}

// NIF de empresa português com dígito de controlo correto.
// 509123457: soma ponderada=158, 158%11=4, dígito=11-4=7 ✓
const _kNifEmpresa = '509123457';
// NIF de cliente português.
// 123456789: 1×9+2×8+3×7+4×6+5×5+6×4+7×3+8×2 = 9+16+21+24+25+24+21+16=156, 156%11=2, dígito=11-2=9 ✓
const _kNifCliente = '123456789';

ClienteModel _clienteExemplo({
  String id = 'c1',
  String nif = _kNifCliente,
}) {
  return ClienteModel(
    id: id,
    nome: 'Cliente Teste',
    nif: nif,
    email: 'cliente@teste.pt',
    telefone: '910000000',
    morada: 'Rua Teste, 1, 1000-001 Lisboa',
    dataCriacao: DateTime(2026, 1, 1),
  );
}

ProdutoModel _produtoExemplo() {
  return ProdutoModel(
    id: 'p1',
    nome: 'Servico Teste',
    descricao: 'Descricao do servico',
    preco: 100.0,
    iva: 23.0,
    unidade: 'un',
    stock: 0,
  );
}

FaturaModel _faturaExemplo({
  String id = 'f1',
  String numero = 'A 2026/1',
  DateTime? data,
  String estado = 'emitida',
  String tipoDocumento = 'Fatura',
}) {
  return FaturaModel(
    id: id,
    numero: numero,
    data: data ?? DateTime(2026, 3, 1),
    clienteId: 'c1',
    clienteNome: 'Cliente Teste',
    clienteNif: _kNifCliente,
    clienteMorada: 'Rua Teste, 1, 1000-001 Lisboa',
    linhas: [
      LinhaFatura(
        produtoId: 'p1',
        produtoNome: 'Servico Teste',
        quantidade: 2,
        precoUnitario: 100.0,
        desconto: 0,
        iva: 23.0,
      ),
    ],
    estado: estado,
    tipoDocumento: tipoDocumento,
    serie: 'A',
    codigoATCUD: 'SIMTEST-1',
    dataCriacao: data ?? DateTime(2026, 3, 1),
  );
}

ConfiguracaoEmpresa _configValida() {
  return ConfiguracaoEmpresa.padrao().copyWith(
    nomeEmpresa: 'Empresa Teste Lda',
    nif: _kNifEmpresa,
    morada: 'Avenida da Liberdade, 1',
    codigoPostal: '1250-141',
    localidade: 'Lisboa',
    pais: 'Portugal',
  );
}

void main() {
  tearDown(() {
    BackupService.setDirectoryPickerOverride(null);
  });

  group('SaftPeriodo', () {
    test('contem inclui data dentro do periodo', () {
      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 12, 31),
      );
      expect(periodo.contem(DateTime(2026, 6, 15)), isTrue);
    });

    test('contem exclui data anterior ao inicio', () {
      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 3, 1),
        dataFim: DateTime(2026, 12, 31),
      );
      expect(periodo.contem(DateTime(2026, 2, 28)), isFalse);
    });

    test('contem exclui data posterior ao fim', () {
      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 6, 30),
      );
      expect(periodo.contem(DateTime(2026, 7, 1)), isFalse);
    });

    test('contem inclui datas nas extremidades', () {
      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 3, 1),
        dataFim: DateTime(2026, 3, 31),
      );
      expect(periodo.contem(DateTime(2026, 3, 1)), isTrue);
      expect(periodo.contem(DateTime(2026, 3, 31, 23, 59)), isTrue);
    });
  });

  group('SaftExportService - validação de configuração', () {
    test('retorna erro quando empresa sem NIF válido', () async {
      if (!Platform.isLinux) return;

      final storage = FakeStorageService();
      // NIF '000000000' falha a validação do dígito de controlo da AT.
      await storage.saveConfiguracaoEmpresa(
        ConfiguracaoEmpresa.padrao().copyWith(nif: '000000000'),
      );
      await storage.saveFatura(_faturaExemplo());

      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 12, 31),
      );

      final resultado = await SaftExportService.exportarSaft(
        storage: storage,
        periodo: periodo,
      );

      expect(resultado.sucesso, isFalse);
      expect(resultado.mensagem, contains('NIF'));
    });

    test('retorna erro sem faturas no período', () async {
      if (!Platform.isLinux) return;

      final storage = FakeStorageService();
      // Configuração com NIF válido para que a validação passe.
      await storage.saveConfiguracaoEmpresa(_configValida());
      // Fatura de 2025 fora do período 2026.
      await storage.saveFatura(_faturaExemplo(data: DateTime(2025, 6, 1)));

      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 12, 31),
      );

      final resultado = await SaftExportService.exportarSaft(
        storage: storage,
        periodo: periodo,
      );

      expect(resultado.sucesso, isFalse);
      // Mensagem menciona período ou ausência de faturas.
      final mensagemMin = resultado.mensagem.toLowerCase();
      expect(
        mensagemMin.contains('periodo') ||
        mensagemMin.contains('per\u00edodo') ||
        mensagemMin.contains('fatura'),
        isTrue,
        reason: 'Mensagem inesperada: ${resultado.mensagem}',
      );
    });
  });

  group('SaftExportService - exportação Linux', () {
    test('gera ficheiro XML com extensão correcta', () async {
      if (!Platform.isLinux) return;

      final storage = FakeStorageService();
      final dir = await Directory.systemTemp.createTemp('facturio_saft_test_');
      BackupService.setDirectoryPickerOverride(() async => dir.path);

      await storage.saveConfiguracaoEmpresa(
        _configValida().copyWith(diretorioBackup: dir.path),
      );
      await storage.saveCliente(_clienteExemplo());
      await storage.saveProduto(_produtoExemplo());
      await storage.saveFatura(_faturaExemplo());

      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 12, 31),
      );

      final resultado = await SaftExportService.exportarSaft(
        storage: storage,
        periodo: periodo,
      );

      expect(resultado.sucesso, isTrue, reason: resultado.mensagem);
      expect(resultado.caminhoFicheiro, endsWith('.xml'));
      expect(resultado.totalFaturas, 1);

      final ficheiro = File(resultado.caminhoFicheiro);
      expect(await ficheiro.exists(), isTrue);

      final conteudo = await ficheiro.readAsString();
      expect(conteudo, contains('<AuditFile'));
      expect(conteudo, contains('<Header>'));
      expect(conteudo, contains('<SalesInvoices>'));
      expect(conteudo, contains('<Invoice>'));
      expect(conteudo, contains(_kNifEmpresa));
      expect(conteudo, contains('SIMTEST-1'));

      await ficheiro.delete();
      await dir.delete(recursive: true);
    });

    test('XML inclui dados de empresa, cliente e produto', () async {
      if (!Platform.isLinux) return;

      final storage = FakeStorageService();
      final dir = await Directory.systemTemp.createTemp('facturio_saft_xml_');
      BackupService.setDirectoryPickerOverride(() async => dir.path);

      await storage.saveConfiguracaoEmpresa(
        _configValida().copyWith(diretorioBackup: dir.path),
      );
      await storage.saveCliente(_clienteExemplo(nif: _kNifCliente));
      await storage.saveProduto(_produtoExemplo());
      await storage.saveFatura(_faturaExemplo());

      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 12, 31),
      );

      final resultado = await SaftExportService.exportarSaft(
        storage: storage,
        periodo: periodo,
      );

      expect(resultado.sucesso, isTrue, reason: resultado.mensagem);

      final conteudo = await File(resultado.caminhoFicheiro).readAsString();
      expect(conteudo, contains('<CompanyName>Empresa Teste Lda</CompanyName>'));
      expect(conteudo, contains(_kNifEmpresa));
      expect(conteudo, contains('<Customer>'));
      expect(conteudo, contains('<Product>'));
      expect(conteudo, contains('<InvoiceType>FT</InvoiceType>'));
      expect(conteudo, contains('<TaxType>IVA</TaxType>'));
      expect(conteudo, contains('<TaxCode>NOR</TaxCode>'));

      await File(resultado.caminhoFicheiro).delete();
      await dir.delete(recursive: true);
    });

    test('nota de credito exportada com tipo NC', () async {
      if (!Platform.isLinux) return;

      final storage = FakeStorageService();
      final dir = await Directory.systemTemp.createTemp('facturio_saft_nc_');

      await storage.saveConfiguracaoEmpresa(
        _configValida().copyWith(diretorioBackup: dir.path),
      );
      await storage.saveCliente(_clienteExemplo());
      await storage.saveProduto(_produtoExemplo());
      await storage.saveFatura(
        _faturaExemplo(
          id: 'nc1',
          numero: 'A NC 2026/1',
          tipoDocumento: 'Nota de Crédito',
        ),
      );

      final periodo = SaftPeriodo(
        dataInicio: DateTime(2026, 1, 1),
        dataFim: DateTime(2026, 12, 31),
      );

      final resultado = await SaftExportService.exportarSaft(
        storage: storage,
        periodo: periodo,
      );

      expect(resultado.sucesso, isTrue, reason: resultado.mensagem);

      final conteudo = await File(resultado.caminhoFicheiro).readAsString();
      expect(conteudo, contains('<InvoiceType>NC</InvoiceType>'));

      await File(resultado.caminhoFicheiro).delete();
      await dir.delete(recursive: true);
    });
  });
}
