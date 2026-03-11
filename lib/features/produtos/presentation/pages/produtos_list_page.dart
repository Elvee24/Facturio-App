import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../providers/produtos_provider.dart';

class ProdutosListPage extends ConsumerStatefulWidget {
  const ProdutosListPage({super.key});

  @override
  ConsumerState<ProdutosListPage> createState() => _ProdutosListPageState();
}

class _ProdutosListPageState extends ConsumerState<ProdutosListPage> {
  String _searchQuery = '';

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final produtosAsync = ref.watch(produtosProvider);
    final produtosFiltrados = ref.watch(produtoSearchProvider(_searchQuery));
    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Produtos', en: 'Products')),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primaryContainer.withValues(alpha: 0.8),
                    colors.surface,
                  ],
                ),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _t(context, pt: 'Pesquisar produtos...', en: 'Search products...'),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.inventory_2, size: 18),
                    label: produtosAsync.when(
                      data: (produtos) => Text('${produtosFiltrados.length}/${produtos.length}'),
                      loading: () => const Text('...'),
                      error: (_, _) => const Text('0/0'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: produtosAsync.when(
              data: (produtos) {
                if (produtosFiltrados.isEmpty) {
                  return Center(
                    child: Text(_t(context, pt: 'Nenhum produto encontrado', en: 'No products found')),
                  );
                }
                
                return ListView.builder(
                  itemCount: produtosFiltrados.length,
                  itemBuilder: (context, index) {
                    final produto = produtosFiltrados[index];
                    final stockBaixo = produto.stock < 10;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer,
                          child: Text(
                            produto.nome[0].toUpperCase(),
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                        ),
                        title: Text(produto.nome),
                        subtitle: Text(
                          '${formatoMoeda.format(produto.preco)} | IVA: ${produto.iva}% | Stock: ${produto.stock}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (stockBaixo)
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(Icons.warning, color: Colors.orange, size: 16),
                              ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit),
                                      const SizedBox(width: 8),
                                      Text(_t(context, pt: 'Editar', en: 'Edit')),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(
                                        _t(context, pt: 'Eliminar', en: 'Delete'),
                                        style: const TextStyle(color: Colors.red),
                                      ),
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
              error: (error, _) => Center(
                child: Text('${_t(context, pt: 'Erro', en: 'Error')}: $error'),
              ),
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

  Future<void> _confirmarEliminar(BuildContext context, String id, String nome) async {
    final confirmado = await UiHelpers.mostrarDialogoConfirmacao(
      context,
      titulo: _t(context, pt: 'Confirmar Eliminação', en: 'Confirm Deletion'),
      mensagem: _t(
        context,
        pt: 'Tem a certeza de que deseja eliminar o produto "$nome"?',
        en: 'Are you sure you want to delete product "$nome"?',
      ),
      textoBotaoConfirmar: _t(context, pt: 'Eliminar', en: 'Delete'),
      acaoDestruidora: true,
    );

    if (confirmado && context.mounted) {
      try {
        await ref.read(produtosProvider.notifier).deleteProduto(id);
        if (context.mounted) {
          UiHelpers.mostrarSnackBar(
            context,
            mensagem: _t(context, pt: 'Produto eliminado com sucesso', en: 'Product deleted successfully'),
            tipo: TipoSnackBar.sucesso,
          );
        }
      } catch (e) {
        if (context.mounted) {
          UiHelpers.mostrarSnackBar(
            context,
            mensagem: '${_t(context, pt: 'Erro ao eliminar', en: 'Error deleting')}: $e',
            tipo: TipoSnackBar.erro,
          );
        }
      }
    }
  }
}
