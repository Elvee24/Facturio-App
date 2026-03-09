import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../providers/clientes_provider.dart';

class ClientesListPage extends ConsumerStatefulWidget {
  const ClientesListPage({super.key});

  @override
  ConsumerState<ClientesListPage> createState() => _ClientesListPageState();
}

class _ClientesListPageState extends ConsumerState<ClientesListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesProvider);
    final clientesFiltrados = ref.watch(clienteSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(showText: true, text: 'Clientes'),
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
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar clientes...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Lista de clientes
          Expanded(
            child: clientesAsync.when(
              data: (_) {
                if (clientesFiltrados.isEmpty) {
                  return const Center(
                    child: Text('Nenhum cliente encontrado'),
                  );
                }
                
                return ListView.builder(
                  itemCount: clientesFiltrados.length,
                  itemBuilder: (context, index) {
                    final cliente = clientesFiltrados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(cliente.nome[0].toUpperCase()),
                        ),
                        title: Text(cliente.nome),
                        subtitle: Text('NIF: ${cliente.nif}\n${cliente.email}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton(
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
              error: (error, __) => Center(
                child: Text('Erro: $error'),
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

  void _confirmarEliminar(BuildContext context, String id, String nome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminação'),
        content: Text('Tem certeza que deseja eliminar o cliente "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(clientesProvider.notifier).deleteCliente(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente eliminado')),
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
