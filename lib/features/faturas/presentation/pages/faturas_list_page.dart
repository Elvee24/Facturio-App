import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../providers/faturas_provider.dart';

class FaturasListPage extends ConsumerStatefulWidget {
  const FaturasListPage({super.key});

  @override
  ConsumerState<FaturasListPage> createState() => _FaturasListPageState();
}

class _FaturasListPageState extends ConsumerState<FaturasListPage> {
  @override
  Widget build(BuildContext context) {
    final faturasAsync = ref.watch(faturasProvider);
    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');
    final formatoData = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(showText: true, text: 'Faturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(faturasProvider.notifier).loadFaturas();
            },
          ),
        ],
      ),
      body: faturasAsync.when(
        data: (faturas) {
          if (faturas.isEmpty) {
            return const Center(
              child: Text('Nenhuma fatura registada'),
            );
          }
          
          return ListView.builder(
            itemCount: faturas.length,
            itemBuilder: (context, index) {
              final fatura = faturas[index];
              Color estadoCor;
              IconData estadoIcon;
              
              switch (fatura.estado) {
                case 'emitida':
                  estadoCor = Colors.blue;
                  estadoIcon = Icons.description;
                  break;
                case 'paga':
                  estadoCor = Colors.green;
                  estadoIcon = Icons.check_circle;
                  break;
                case 'cancelada':
                  estadoCor = Colors.red;
                  estadoIcon = Icons.cancel;
                  break;
                default:
                  estadoCor = Colors.grey;
                  estadoIcon = Icons.description;
              }
              
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ExpansionTile(
                  leading: Icon(estadoIcon, color: estadoCor),
                  title: Text('Fatura ${fatura.numero}'),
                  subtitle: Text(
                    'Cliente: ${fatura.clienteNome}\n${formatoData.format(fatura.data)}',
                  ),
                  trailing: Text(
                    formatoMoeda.format(fatura.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado: ${fatura.estado}'),
                          const SizedBox(height: 8),
                          Text('Produtos: ${fatura.linhas.length}'),
                          Text('Subtotal: ${formatoMoeda.format(fatura.subtotal)}'),
                          Text('IVA: ${formatoMoeda.format(fatura.totalIva)}'),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  try {
                                    final cliente = await ref
                                        .read(clientesProvider.notifier)
                                        .getCliente(fatura.clienteId);
                                    if (cliente != null) {
                                      await PdfService.compartilharFatura(fatura, cliente);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro: $e')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Partilhar PDF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, __) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.faturaForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
