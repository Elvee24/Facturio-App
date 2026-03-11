import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:facturio/core/models/configuracao_empresa.dart';
import 'package:facturio/core/services/backup_service.dart';
import 'package:facturio/core/services/storage_service.dart';
import 'package:facturio/features/clientes/data/models/cliente_model.dart';
import 'package:facturio/features/faturas/data/models/fatura_model.dart';
import 'package:facturio/features/produtos/data/models/produto_model.dart';
import 'package:facturio/shared/models/linha_fatura.dart';

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
  Future<void> clearAll() async {
    _clientes.clear();
    _produtos.clear();
    _faturas.clear();
  }

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
}

void main() {
  tearDown(() {
    BackupService.setDirectoryPickerOverride(null);
  });

  test('First backup export selects and saves backup directory', () async {
    if (!Platform.isLinux) {
      return;
    }

    final storage = FakeStorageService();
    final backupDir = await Directory.systemTemp.createTemp('facturio_first_backup_');
    BackupService.setDirectoryPickerOverride(() async => backupDir.path);

    await storage.saveConfiguracaoEmpresa(
      ConfiguracaoEmpresa.padrao().copyWith(diretorioBackup: ''),
    );

    await storage.saveCliente(
      ClienteModel(
        id: 'first-backup-client',
        nome: 'Primeiro Backup',
        nif: '123123123',
        email: 'primeiro@exemplo.pt',
        telefone: '930000000',
        morada: 'Rua Teste',
        dataCriacao: DateTime(2026, 3, 11),
      ),
    );

    final resultado = await BackupService.exportarDadosAplicacao(storage);

    expect(resultado.sucesso, isTrue);
    expect(resultado.caminhoFicheiro.startsWith('${backupDir.path}/'), isTrue);

    final configAtualizada = await storage.getConfiguracaoEmpresa();
    expect(configAtualizada.diretorioBackup, backupDir.path);

    final ficheiro = File(resultado.caminhoFicheiro);
    expect(await ficheiro.exists(), isTrue);

    await ficheiro.delete();
    await backupDir.delete(recursive: true);
  });

  test('Backup export on Linux writes file to configured backup directory', () async {
    if (!Platform.isLinux) {
      return;
    }

    final storage = FakeStorageService();
    final backupDir = await Directory.systemTemp.createTemp('facturio_backup_test_');
    await storage.saveConfiguracaoEmpresa(
      ConfiguracaoEmpresa.padrao().copyWith(diretorioBackup: backupDir.path),
    );

    await storage.saveCliente(
      ClienteModel(
        id: 'cx1',
        nome: 'Cliente Export',
        nif: '123123123',
        email: 'export@exemplo.pt',
        telefone: '930000000',
        morada: 'Rua Export',
        dataCriacao: DateTime(2026, 3, 11),
      ),
    );

    final resultado = await BackupService.exportarDadosAplicacao(storage);

    expect(resultado.sucesso, isTrue);
    expect(resultado.caminhoFicheiro.isNotEmpty, isTrue);
    expect(resultado.caminhoFicheiro.endsWith('.backup'), isTrue);
    expect(resultado.caminhoFicheiro.startsWith('${backupDir.path}/'), isTrue);

    final ficheiro = File(resultado.caminhoFicheiro);
    expect(await ficheiro.exists(), isTrue);

    await ficheiro.delete();
    await backupDir.delete(recursive: true);
  });

  test('Backup export/import roundtrip restores original data', () async {
    final storage = FakeStorageService();

    final clienteOriginal = ClienteModel(
      id: 'c1',
      nome: 'Cliente Original',
      nif: '123456789',
      email: 'cliente@exemplo.pt',
      telefone: '910000000',
      morada: 'Rua A',
      dataCriacao: DateTime(2026, 3, 1),
    );

    final produtoOriginal = ProdutoModel(
      id: 'p1',
      nome: 'Servico',
      descricao: 'Servico teste',
      preco: 100,
      iva: 23,
      unidade: 'un',
      stock: 10,
    );

    final faturaOriginal = FaturaModel(
      id: 'f1',
      numero: '2026/001',
      data: DateTime(2026, 3, 2),
      clienteId: 'c1',
      clienteNome: 'Cliente Original',
      linhas: [
        LinhaFatura(
          produtoId: 'p1',
          produtoNome: 'Servico',
          quantidade: 1,
          precoUnitario: 100,
          desconto: 0,
          iva: 23,
        ),
      ],
      estado: 'Emitida',
      tipoDocumento: 'Fatura',
      serie: 'A',
      dataCriacao: DateTime(2026, 3, 2),
    );

    await storage.saveCliente(clienteOriginal);
    await storage.saveProduto(produtoOriginal);
    await storage.saveFatura(faturaOriginal);

    final backupFile = await BackupService.criarFicheiroBackup(storage);
    expect(await backupFile.exists(), isTrue);

    // Simula alteração dos dados após exportação.
    await storage.clearAll();
    await storage.saveCliente(
      ClienteModel(
        id: 'c2',
        nome: 'Cliente Alterado',
        nif: '987654321',
        email: 'alterado@exemplo.pt',
        telefone: '920000000',
        morada: 'Rua B',
        dataCriacao: DateTime(2026, 3, 3),
      ),
    );

    expect((await storage.getClientes()).length, 1);
    expect((await storage.getProdutos()).length, 0);
    expect((await storage.getFaturas()).length, 0);

    final resultado = await BackupService.restaurarFicheiro(storage, backupFile.path);

    expect(resultado.clientes, 1);
    expect(resultado.produtos, 1);
    expect(resultado.faturas, 1);

    final clientesRestaurados = await storage.getClientes();
    final produtosRestaurados = await storage.getProdutos();
    final faturasRestauradas = await storage.getFaturas();

    expect(clientesRestaurados.single.nome, 'Cliente Original');
    expect(produtosRestaurados.single.nome, 'Servico');
    expect(faturasRestauradas.single.numero, '2026/001');

    if (await backupFile.exists()) {
      await File(backupFile.path).delete();
    }
  });
}
