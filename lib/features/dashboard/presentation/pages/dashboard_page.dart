import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/admin_auth_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/pagamentos_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../produtos/presentation/providers/produtos_provider.dart';
import '../../../faturas/presentation/providers/faturas_provider.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final clientesAsync = ref.watch(clientesProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final faturasAsync = ref.watch(faturasProvider);
    final pagamentosAsync = ref.watch(pagamentosProvider);
    final totalFaturado = ref.watch(totalFaturadoProvider);
    final produtosStockBaixo = ref.watch(produtosStockBaixoProvider);

    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Dashboard', en: 'Dashboard')),
      ),
      drawer: _buildDrawer(context, ref),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    colors.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(context, pt: 'Centro de Faturação', en: 'Billing Center'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t(
                      context,
                      pt: 'Resumo rápido de clientes, produtos e faturação.',
                      en: 'Quick overview of customers, products, and billing.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cards de estatísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    _t(context, pt: 'Clientes', en: 'Customers'),
                    clientesAsync.when(
                      data: (clientes) => clientes.length.toString(),
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    Icons.people,
                    colors.primary,
                    () => context.push(AppRoutes.clientes),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    _t(context, pt: 'Produtos', en: 'Products'),
                    produtosAsync.when(
                      data: (produtos) => produtos.length.toString(),
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    Icons.inventory,
                    Colors.green.shade700,
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
                    _t(context, pt: 'Faturas', en: 'Invoices'),
                    faturasAsync.when(
                      data: (faturas) => faturas.length.toString(),
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    Icons.receipt_long,
                    Colors.orange.shade700,
                    () => context.push(AppRoutes.faturas),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    _t(context, pt: 'Total Faturado', en: 'Total Invoiced'),
                    formatoMoeda.format(totalFaturado),
                    Icons.euro,
                    colors.secondary,
                    null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Resumo Financeiro
            Text(
              _t(context, pt: 'Resumo Financeiro', en: 'Financial Summary'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            faturasAsync.when(
              data: (faturas) {
                return pagamentosAsync.when(
                  data: (pagamentosMap) {
                    // Gerar resumo financeiro
                    final resumo = PagamentosService.gerarResumoFinanceiro(
                      faturas: faturas,
                      pagamentosPorFatura: pagamentosMap,
                    );

                    final totalRecebido = resumo.totalRecebido;
                    final totalEmDivida = resumo.totalEmDivida;
                    final faturasPagas = resumo.faturasCompletamentePagas;
                    final faturasNaoPagas = resumo.faturasNaoPagas;
                    final faturasParciais = resumo.faturasParcialmentePagas;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoTile(
                                    context,
                                    _t(context, pt: 'Total Recebido', en: 'Total Received'),
                                    formatoMoeda.format(totalRecebido),
                                    Icons.check_circle,
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInfoTile(
                                    context,
                                    _t(context, pt: 'Em Dívida', en: 'Outstanding'),
                                    formatoMoeda.format(totalEmDivida),
                                    Icons.pending,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildStatusChip(
                                  _t(context, pt: 'Pagas', en: 'Paid'),
                                  faturasPagas,
                                  Colors.green,
                                ),
                                _buildStatusChip(
                                  _t(context, pt: 'Parciais', en: 'Partial'),
                                  faturasParciais,
                                  Colors.orange,
                                ),
                                _buildStatusChip(
                                  _t(context, pt: 'Não Pagas', en: 'Unpaid'),
                                  faturasNaoPagas,
                                  Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stackTrace) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_t(context, pt: 'Erro ao carregar pagamentos', en: 'Error loading payments')),
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_t(context, pt: 'Erro ao carregar dados', en: 'Error loading data')),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Alertas de stock baixo
            if (produtosStockBaixo.isNotEmpty) ...[
              Text(
                _t(context, pt: 'Alertas', en: 'Alerts'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.orange.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text('${produtosStockBaixo.length} ${_t(context, pt: 'produtos com stock baixo', en: 'products with low stock')}'),
                  subtitle: Text(_t(context, pt: 'Clique para ver detalhes', en: 'Click to view details')),
                  onTap: () => context.push(AppRoutes.produtos),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Últimas faturas
            Text(
              _t(context, pt: 'Últimas Faturas', en: 'Latest Invoices'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            faturasAsync.when(
              data: (faturas) {
                final ultimasFaturas = faturas.take(5).toList();
                if (ultimasFaturas.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_t(context, pt: 'Nenhuma fatura registada', en: 'No invoices recorded')),
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
              error: (_, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_t(context, pt: 'Erro ao carregar faturas', en: 'Error loading invoices')),
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
        borderRadius: BorderRadius.circular(14),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Column(
      children: [
        Chip(
          avatar: CircleAvatar(
            backgroundColor: color,
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          label: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          backgroundColor: color.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
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
            title: Text(_t(context, pt: 'Dashboard', en: 'Dashboard')),
            onTap: () {
              Navigator.pop(context);
              context.go(AppRoutes.dashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(_t(context, pt: 'Clientes', en: 'Customers')),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.clientes);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(_t(context, pt: 'Produtos', en: 'Products')),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.produtos);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(_t(context, pt: 'Faturas', en: 'Invoices')),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.faturas);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(_t(context, pt: 'Personalização', en: 'Customization')),
            subtitle: Text(_t(context, pt: 'Tema, cores e aparência', en: 'Theme, colors, and appearance')),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.personalizacao);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(_t(context, pt: 'Configurações da Empresa', en: 'Company Settings')),
            onTap: () async {
              Navigator.pop(context);

              final pinController = TextEditingController();
              final pin = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(_t(context, pt: 'Acesso de Administrador', en: 'Administrator Access')),
                  content: TextField(
                    controller: pinController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'PIN de administrador', en: 'Administrator PIN'),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 12,
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(pinController.text.trim()),
                      child: Text(_t(context, pt: 'Entrar', en: 'Enter')),
                    ),
                  ],
                ),
              );

              if (pin == null || pin.isEmpty || !context.mounted) {
                return;
              }

              if (!await AdminAuthService.validarPin(pin)) {
                if (!context.mounted) return;
                UiHelpers.mostrarSnackBar(
                  context,
                  mensagem: _t(context, pt: 'PIN de administrador inválido.', en: 'Invalid administrator PIN.'),
                  tipo: TipoSnackBar.erro,
                );
                return;
              }

              if (!context.mounted) return;

              context.push(AppRoutes.configuracoes);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(_t(context, pt: 'Exportar dados', en: 'Export data')),
            subtitle: Text(_t(context, pt: 'Clientes, produtos e faturas (JSON)', en: 'Customers, products, and invoices (JSON)')),
            onTap: () async {
              Navigator.pop(context);
              final storage = StorageService();
              final resultado = await BackupService.exportarDadosAplicacao(storage);
              if (context.mounted) {
                if (resultado.sucesso) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem: resultado.mensagem,
                    tipo: TipoSnackBar.sucesso,
                  );
                } else {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem: resultado.mensagem,
                    tipo: TipoSnackBar.erro,
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: Text(_t(context, pt: 'Abrir pasta de backups', en: 'Open backup folder')),
            subtitle: Text(_t(context, pt: 'Abre a pasta onde os backups são guardados', en: 'Open the folder where backups are saved')),
            onTap: () async {
              Navigator.pop(context);
              final cfg = ref.read(configuracoesProvider).maybeWhen(
                    data: (value) => value,
                    orElse: () => null,
                  );
              final abriu = await BackupService.abrirPastaBackups(cfg?.diretorioBackup);
              if (context.mounted) {
                UiHelpers.mostrarSnackBar(
                  context,
                  mensagem: abriu
                      ? _t(context, pt: 'Pasta de backups aberta.', en: 'Backup folder opened.')
                      : _t(context, pt: 'Não foi possível abrir a pasta de backups.', en: 'Could not open backup folder.'),
                  tipo: abriu ? TipoSnackBar.sucesso : TipoSnackBar.erro,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(_t(context, pt: 'Importar dados', en: 'Import data')),
            subtitle: Text(_t(context, pt: 'Substitui clientes, produtos e faturas atuais', en: 'Replaces current customers, products, and invoices')),
            onTap: () async {
              Navigator.pop(context);

              final confirmar = await UiHelpers.mostrarDialogoConfirmacao(
                context,
                titulo: _t(context, pt: 'Importar dados', en: 'Import data'),
                mensagem: _t(context, pt: 'Esta ação vai substituir os dados atuais de clientes, produtos e faturas. Deseja continuar?', en: 'This action will replace current customer, product, and invoice data. Continue?'),
                textoBotaoConfirmar: _t(context, pt: 'Importar', en: 'Import'),
                acaoDestruidora: true,
              );

              if (!confirmar || !context.mounted) return;

              final storage = StorageService();
              try {
                final resultado = await BackupService.importarDadosAplicacao(storage);
                if (resultado == null) {
                  if (context.mounted) {
                    UiHelpers.mostrarSnackBar(
                      context,
                      mensagem: _t(context, pt: 'Importação cancelada.', en: 'Import cancelled.'),
                      tipo: TipoSnackBar.info,
                    );
                  }
                  return;
                }

                await ref.read(clientesProvider.notifier).loadClientes();
                await ref.read(produtosProvider.notifier).loadProdutos();
                await ref.read(faturasProvider.notifier).loadFaturas();

                if (context.mounted) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem:
                        '${_t(context, pt: 'Importação concluída', en: 'Import completed')}: ${resultado.clientes} ${_t(context, pt: 'clientes', en: 'customers')}, ${resultado.produtos} ${_t(context, pt: 'produtos', en: 'products')} ${_t(context, pt: 'e', en: 'and')} ${resultado.faturas} ${_t(context, pt: 'faturas', en: 'invoices')}.',
                    tipo: TipoSnackBar.sucesso,
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                final erro = e.toString();
                final mensagem = erro.toLowerCase().contains('zenity')
                    ? _t(
                        context,
                        pt: 'File picker indisponível no Linux sem zenity. Instale com: sudo apt install zenity',
                        en: 'File picker unavailable on Linux without zenity. Install with: sudo apt install zenity',
                      )
                    : '${_t(context, pt: 'Erro ao importar dados', en: 'Error importing data')}: $e';
                if (context.mounted) {
                  UiHelpers.mostrarSnackBar(
                    context,
                    mensagem: mensagem,
                    tipo: TipoSnackBar.erro,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
