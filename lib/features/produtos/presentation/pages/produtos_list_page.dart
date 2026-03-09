import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../providers/produtos_provider.dart';

class ProdutosListPage extends ConsumerStatefulWidget {
  const ProdutosListPage({super.key});

  @override
  ConsumerState<ProdutosListPage> createState() => _ProdutosListPageState();
}

class _ProdutosListPageState extends ConsumerState<ProdutosListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(produtosProvider);
    final produtosFiltrados = ref.watch(produtoSearchProvider(_searchQuery));
    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(showText: true, text: 'Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(produtosProvider.notifier).loadProdutos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar produtos...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: produtosAsync.when(
              data: (_) {
                if (produtosFiltrados.isEmpty) {
                  return const Center(
                    child: Text('Nenhum produto encontrado'),
                  );
                }
                
                return ListView.builder(
                  itemCount: produtosFiltrados.length,
                  itemBuilder: (context, index) {
                    final produto = produtosFiltrados[index];
                    final stockBaixo = produto.stock < 10;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(produto.nome[0].toUpperCase()),
                        ),
                        title: Text(produto.nome),
                        subtitle: Text(
                          '${formatoMoeda.format(produto.preco)} | IVA: ${produto.iva}% | Stock: ${produto.stock}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (stockBaixo)
                              const Icon(Icons.warning, color: Colors.orange),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'editar') {
                                  context.push('${AppRoutes.produtoForm}?id=${produto.id}');
                                } else if (value == 'eliminar') {
                                  _confirmarEliminar(context, produto.id, produto.nome);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push('${AppRoutes.produtoForm}?id=${produto.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, __) => Center(child: Text('Erro: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.produtoForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminação'),
        content: Text('Tem certeza que deseja eliminar o produto "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(produtosProvider.notifier).deleteProduto(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produto eliminado')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
