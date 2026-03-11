import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/pagamentos_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../pagamentos/presentation/providers/pagamentos_provider.dart';
import '../../../pagamentos/presentation/widgets/status_pagamento_widget.dart';
import '../../../pagamentos/presentation/pages/registar_pagamento_page.dart';
import '../providers/faturas_provider.dart';

/// Página de detalhe de uma fatura específica com histórico de pagamentos.
class FaturaDetailPage extends ConsumerWidget {
  final String faturaId;

  const FaturaDetailPage({super.key, required this.faturaId});

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final faturasAsync = ref.watch(faturasProvider);
    final pagamentosAsync = ref.watch(pagamentosProvider);
    final formatoMoeda = NumberFormat.currency(locale: 'pt_PT', symbol: '€');
    final formatoData = DateFormat('dd/MM/yyyy');

    return faturasAsync.when(
      data: (faturas) {
        final fatura = faturas.firstWhere(
          (f) => f.id == faturaId,
          orElse: () => throw Exception(_t(context, pt: 'Fatura não encontrada', en: 'Invoice not found')),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('${_t(context, pt: 'Fatura', en: 'Invoice')} ${fatura.numero}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: _t(context, pt: 'Imprimir', en: 'Print'),
                onPressed: () async {
                  final dadosInsuficientes =
                      _t(context, pt: 'Dados insuficientes', en: 'Insufficient data');
                  final erroImprimir =
                      _t(context, pt: 'Erro ao imprimir', en: 'Error printing');
                  try {
                    final cliente = await ref
                        .read(clientesProvider.notifier)
                        .getCliente(fatura.clienteId);
                    final config = ref.read(configuracoesProvider).value;

                    if (config == null || cliente == null) {
                      throw Exception(dadosInsuficientes);
                    }

                    await PdfService.imprimirFatura(fatura, cliente, config);
                  } catch (e) {
                    if (context.mounted) {
                      UiHelpers.mostrarSnackBar(
                        context,
                        mensagem: '$erroImprimir: $e',
                        tipo: TipoSnackBar.erro,
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: _t(context, pt: 'Partilhar', en: 'Share'),
                onPressed: () async {
                  final dadosInsuficientes =
                      _t(context, pt: 'Dados insuficientes', en: 'Insufficient data');
                  final erroPartilhar =
                      _t(context, pt: 'Erro ao partilhar', en: 'Error sharing');
                  try {
                    final cliente = await ref
                        .read(clientesProvider.notifier)
                        .getCliente(fatura.clienteId);
                    final config = ref.read(configuracoesProvider).value;

                    if (config == null || cliente == null) {
                      throw Exception(dadosInsuficientes);
                    }

                    await PdfService.compartilharFatura(fatura, cliente, config);
                  } catch (e) {
                    if (context.mounted) {
                      UiHelpers.mostrarSnackBar(
                        context,
                        mensagem: '$erroPartilhar: $e',
                        tipo: TipoSnackBar.erro,
                      );
                    }
                  }
                },
              ),
            ],
          ),
          floatingActionButton: pagamentosAsync.when(
            data: (pagamentosMap) {
              final pagamentos = pagamentosMap[faturaId] ?? [];
              final estaCompleta = PagamentosService.estaCompletamentePaga(fatura, pagamentos);

              if (estaCompleta) {
                return null; // Não mostra botão se já está paga
              }

              return FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegistarPagamentoPage(
                        fatura: fatura,
                        pagamentosExistentes: pagamentos,
                      ),
                    ),
                  );
                  ref.invalidate(pagamentosProvider);
                },
                icon: const Icon(Icons.add),
                label: Text(_t(context, pt: 'Adicionar Pagamento', en: 'Add Payment')),
              );
            },
            loading: () => null,
            error: (error, stackTrace) => null,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho da fatura
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primary, colors.secondary],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_t(context, pt: 'Fatura', en: 'Invoice')} ${fatura.numero}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fatura.clienteNome,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colors.onPrimary.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatoData.format(fatura.data),
                        style: TextStyle(
                          color: colors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status de Pagamento
                pagamentosAsync.when(
                  data: (pagamentosMap) {
                    final pagamentos = pagamentosMap[faturaId] ?? [];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: StatusPagamentoWidget(
                        fatura: fatura,
                        pagamentos: pagamentos,
                        compacto: false,
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_t(context, pt: 'Erro ao carregar pagamentos', en: 'Error loading payments')),
                  ),
                ),

                // Detalhes da Fatura
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(context, pt: 'Resumo Financeiro', en: 'Financial Summary'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        _buildLinhaResumo(_t(context, pt: 'Subtotal', en: 'Subtotal'), formatoMoeda.format(fatura.subtotal)),
                        _buildLinhaResumo('VAT', formatoMoeda.format(fatura.totalIva)),
                        if (fatura.retencaoFonte != null && fatura.retencaoFonte! > 0)
                          _buildLinhaResumo(
                            _t(context, pt: 'Retenção na Fonte', en: 'Withholding Tax'),
                            '- ${formatoMoeda.format(fatura.retencaoFonte)}',
                            color: Colors.red,
                          ),
                        const Divider(),
                        _buildLinhaResumo(
                          _t(context, pt: 'Total', en: 'Total'),
                          formatoMoeda.format(fatura.totalComRetencao),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Produtos/Serviços
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(context, pt: 'Produtos/Serviços', en: 'Products/Services'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: fatura.linhas.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final linha = fatura.linhas[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(linha.produtoNome),
                              subtitle: Text(
                                '${linha.quantidade} x ${formatoMoeda.format(linha.precoUnitario)} (VAT ${linha.iva}%)',
                              ),
                              trailing: Text(
                                formatoMoeda.format(linha.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Histórico de Pagamentos
                pagamentosAsync.when(
                  data: (pagamentosMap) {
                    final pagamentos = pagamentosMap[faturaId] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _t(context, pt: 'Histórico de Pagamentos', en: 'Payment History'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Chip(
                                  label: Text('${pagamentos.length}'),
                                  avatar: const Icon(Icons.payments, size: 18),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (pagamentos.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.payment, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        _t(context, pt: 'Nenhum pagamento registado', en: 'No payment recorded'),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pagamentos.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, index) {
                                  final pagamento = pagamentos[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.check, color: Colors.white),
                                    ),
                                    title: Text(
                                      formatoMoeda.format(pagamento.valor),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pagamento.meioPagamento),
                                        Text(formatoData.format(pagamento.dataPagamento)),
                                        if (pagamento.referencia != null)
                                          Text(
                                            '${_t(context, pt: 'Ref', en: 'Ref')}: ${pagamento.referencia}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        if (pagamento.observacoes != null)
                                          Text(
                                            pagamento.observacoes!,
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () async {
                                        final confirma = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(_t(context, pt: 'Confirmar Remoção', en: 'Confirm Removal')),
                                            content: Text(
                                              _t(
                                                context,
                                                pt: 'Deseja remover o pagamento de ${formatoMoeda.format(pagamento.valor)}?',
                                                en: 'Do you want to remove the payment of ${formatoMoeda.format(pagamento.valor)}?',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: Text(_t(context, pt: 'Remover', en: 'Remove')),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirma == true) {
                                          try {
                                            await ref
                                                .read(pagamentosProvider.notifier)
                                                .removerPagamento(pagamento.id, pagamento.faturaId);

                                            if (context.mounted) {
                                              UiHelpers.mostrarSnackBar(
                                                context,
                                                mensagem: _t(context, pt: 'Pagamento removido com sucesso', en: 'Payment removed successfully'),
                                                tipo: TipoSnackBar.sucesso,
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              UiHelpers.mostrarSnackBar(
                                                context,
                                                mensagem: '${_t(context, pt: 'Erro ao remover pagamento', en: 'Error removing payment')}: $e',
                                                tipo: TipoSnackBar.erro,
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stackTrace) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(_t(context, pt: 'Erro ao carregar histórico', en: 'Error loading history')),
                    ),
                  ),
                ),

                const SizedBox(height: 80), // Espaço para o FAB
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(_t(context, pt: 'Erro', en: 'Error'))),
        body: Center(
          child: Text('${_t(context, pt: 'Erro ao carregar fatura', en: 'Error loading invoice')}: $error'),
        ),
      ),
    );
  }

  Widget _buildLinhaResumo(String label, String valor, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
              color: color,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
