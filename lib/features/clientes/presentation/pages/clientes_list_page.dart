import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../providers/clientes_provider.dart';

class ClientesListPage extends ConsumerStatefulWidget {
  const ClientesListPage({super.key});

  @override
  ConsumerState<ClientesListPage> createState() => _ClientesListPageState();
}

class _ClientesListPageState extends ConsumerState<ClientesListPage> {
  String _searchQuery = '';

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final clientesAsync = ref.watch(clientesProvider);
    final clientesFiltrados = ref.watch(clienteSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Clientes', en: 'Customers')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(clientesProvider.notifier).loadClientes();
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
                        hintText: _t(context, pt: 'Pesquisar clientes...', en: 'Search customers...'),
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
                    avatar: const Icon(Icons.people, size: 18),
                    label: clientesAsync.when(
                      data: (clientes) => Text('${clientesFiltrados.length}/${clientes.length}'),
                      loading: () => const Text('...'),
                      error: (_, _) => const Text('0/0'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: clientesAsync.when(
              data: (clientes) {
                if (clientesFiltrados.isEmpty) {
                  return Center(
                    child: Text(_t(context, pt: 'Nenhum cliente encontrado', en: 'No customers found')),
                  );
                }
                
                return ListView.builder(
                  itemCount: clientesFiltrados.length,
                  itemBuilder: (context, index) {
                    final cliente = clientesFiltrados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer,
                          child: Text(
                            cliente.nome[0].toUpperCase(),
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                        ),
                        title: Text(cliente.nome),
                        subtitle: Text(
                          'NIF: ${cliente.nif}\n${cliente.email.isEmpty ? _t(context, pt: 'Sem email', en: 'No email') : cliente.email}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton(
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
                              context.push('${AppRoutes.clienteForm}?id=${cliente.id}');
                            } else if (value == 'eliminar') {
                              _confirmarEliminar(context, cliente.id, cliente.nome);
                            }
                          },
                        ),
                        onTap: () {
                          context.push('${AppRoutes.clienteForm}?id=${cliente.id}');
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
          context.push(AppRoutes.clienteForm);
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
        pt: 'Tem a certeza de que deseja eliminar o cliente "$nome"?',
        en: 'Are you sure you want to delete customer "$nome"?',
      ),
      textoBotaoConfirmar: _t(context, pt: 'Eliminar', en: 'Delete'),
      acaoDestruidora: true,
    );

    if (confirmado && context.mounted) {
      try {
        await ref.read(clientesProvider.notifier).deleteCliente(id);
        if (context.mounted) {
          UiHelpers.mostrarSnackBar(
            context,
            mensagem: _t(context, pt: 'Cliente eliminado com sucesso', en: 'Customer deleted successfully'),
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
