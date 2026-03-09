import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/linha_fatura.dart';
import '../../domain/entities/fatura.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../produtos/presentation/providers/produtos_provider.dart';
import '../providers/faturas_provider.dart';

class FaturaFormPage extends ConsumerStatefulWidget {
  final String? faturaId;

  const FaturaFormPage({super.key, this.faturaId});

  @override
  ConsumerState<FaturaFormPage> createState() => _FaturaFormPageState();
}

class _FaturaFormPageState extends ConsumerState<FaturaFormPage> {
  String? _clienteSelecionadoId;
  String? _clienteSelecionadoNome;
  String _estadoSelecionado = AppConstants.estadoRascunho;
  final List<LinhaFatura> _linhas = [];

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final produtosAsync = ref.watch(produtosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Fatura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seleção de Cliente
            clientesAsync.when(
              data: (clientes) {
                return DropdownButtonFormField<String>(
                  value: _clienteSelecionadoId,
                  decoration: const InputDecoration(
                    labelText: 'Cliente *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  hint: const Text('Selecione um cliente'),
                  items: clientes.map((cliente) {
                    return DropdownMenuItem(
                      value: cliente.id,
                      child: Text(cliente.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final cliente = clientes.firstWhere((c) => c.id == value);
                    setState(() {
                      _clienteSelecionadoId = value;
                      _clienteSelecionadoNome = cliente.nome;
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Erro ao carregar clientes'),
            ),
            const SizedBox(height: 16),

            // Estado da Fatura
            DropdownButtonFormField<String>(
              value: _estadoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.info),
              ),
              items: AppConstants.estadosFatura.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(estado),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _estadoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Linhas da Fatura
            Text(
              'Produtos/Serviços',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            if (_linhas.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum produto adicionado'),
                ),
              )
            else
              ..._linhas.asMap().entries.map((entry) {
                final index = entry.key;
                final linha = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(linha.produtoNome),
                    subtitle: Text('Qtd: ${linha.quantidade} | €${linha.total.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _linhas.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Botão Adicionar Produto
            OutlinedButton.icon(
              onPressed: () => _mostrarDialogoProduto(produtosAsync.value ?? []),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Produto'),
            ),

            const SizedBox(height: 32),

            // Botão Criar Fatura
            ElevatedButton(
              onPressed: _linhas.isEmpty || _clienteSelecionadoId == null
                  ? null
                  : _criarFatura,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Criar Fatura'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoProduto(List produtos) {
    String? produtoSelecionadoId;
    final quantidadeController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              hint: const Text('Selecione um produto'),
              items: produtos.map((produto) {
                return DropdownMenuItem(
                  value: produto.id,
                  child: Text('${produto.nome} - €${produto.preco}'),
                );
              }).toList(),
              onChanged: (value) {
                produtoSelecionadoId = value as String?;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (produtoSelecionadoId != null) {
                final produto = produtos.firstWhere((p) => p.id == produtoSelecionadoId);
                final quantidade = double.tryParse(quantidadeController.text) ?? 1;
                
                setState(() {
                  _linhas.add(LinhaFatura.fromProduto(produto, quantidade));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _criarFatura() async {
    if (_clienteSelecionadoId == null || _clienteSelecionadoNome == null) {
      return;
    }

    try {
      final fatura = Fatura(
        id: '',
        numero: '',
        data: DateTime.now(),
        clienteId: _clienteSelecionadoId!,
        clienteNome: _clienteSelecionadoNome!,
        linhas: _linhas,
        estado: _estadoSelecionado,
      );

      await ref.read(faturasProvider.notifier).addFatura(fatura);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fatura criada')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
}
