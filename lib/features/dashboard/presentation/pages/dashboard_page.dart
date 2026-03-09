import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../produtos/presentation/providers/produtos_provider.dart';
import '../../../faturas/presentation/providers/faturas_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final faturasAsync = ref.watch(faturasProvider);
    final totalFaturado = ref.watch(totalFaturadoProvider);
    final produtosStockBaixo = ref.watch(produtosStockBaixoProvider);

    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(showText: true, text: 'Dashboard'),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cards de estatísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Clientes',
                    clientesAsync.when(
                      data: (clientes) => clientes.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.people,
                    Colors.blue,
                    () => context.push(AppRoutes.clientes),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Produtos',
                    produtosAsync.when(
                      data: (produtos) => produtos.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.inventory,
                    Colors.green,
                    () => context.push(AppRoutes.produtos),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Faturas',
                    faturasAsync.when(
                      data: (faturas) => faturas.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.receipt_long,
                    Colors.orange,
                    () => context.push(AppRoutes.faturas),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Faturado',
                    formatoMoeda.format(totalFaturado),
                    Icons.euro,
                    Colors.purple,
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Alertas de stock baixo
            if (produtosStockBaixo.isNotEmpty) ...[
              Text(
                'Alertas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text('${produtosStockBaixo.length} produtos com stock baixo'),
                  subtitle: const Text('Clique para ver detalhes'),
                  onTap: () => context.push(AppRoutes.produtos),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Últimas faturas
            Text(
              'Últimas Faturas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            faturasAsync.when(
              data: (faturas) {
                final ultimasFaturas = faturas.take(5).toList();
                if (ultimasFaturas.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhuma fatura registada'),
                    ),
                  );
                }
                return Column(
                  children: ultimasFaturas.map((fatura) {
                    return Card(
                      child: ListTile(
                        title: Text(fatura.numero),
                        subtitle: Text(fatura.clienteNome),
                        trailing: Text(
                          formatoMoeda.format(fatura.total),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => context.push(AppRoutes.faturas),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Erro ao carregar faturas'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 32),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Facturio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.dashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.clientes);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Produtos'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.produtos);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Faturas'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.faturas);
            },
          ),
        ],
      ),
    );
  }
}
