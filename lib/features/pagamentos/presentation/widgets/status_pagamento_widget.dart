import 'package:flutter/material.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/services/pagamentos_service.dart';
import '../../../../shared/models/pagamento.dart';
import '../../../faturas/domain/entities/fatura.dart';

/// Widget que exibe o status visual de pagamento de uma fatura.
class StatusPagamentoWidget extends StatelessWidget {
  final Fatura fatura;
  final List<Pagamento> pagamentos;
  final bool compacto;

  const StatusPagamentoWidget({
    super.key,
    required this.fatura,
    required this.pagamentos,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    String t({required String pt, required String en}) =>
        AppText.tr(context, pt: pt, en: en);

    final isPaga = PagamentosService.estaCompletamentePaga(fatura, pagamentos);
    final isParcial = PagamentosService.estaParcialmentePaga(fatura, pagamentos);
    final percentagem = PagamentosService.calcularPercentagemPaga(fatura, pagamentos);
    final totalPago = PagamentosService.calcularTotalPago(pagamentos);
    final valorEmDivida = PagamentosService.calcularValorEmDivida(fatura, pagamentos);
    final totalFatura = fatura.totalComRetencao;

    Color corStatus;
    IconData iconStatus;
    String textoStatus;

    if (isPaga) {
      corStatus = Colors.green;
      iconStatus = Icons.check_circle;
      textoStatus = t(pt: 'Paga', en: 'Paid');
    } else if (isParcial) {
      corStatus = Colors.orange;
      iconStatus = Icons.timelapse;
      textoStatus = t(pt: 'Parcial', en: 'Partial');
    } else {
      corStatus = Colors.red;
      iconStatus = Icons.pending;
      textoStatus = t(pt: 'Não Paga', en: 'Unpaid');
    }

    if (compacto) {
      return _buildCompacto(context, corStatus, iconStatus, textoStatus, percentagem);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(iconStatus, color: corStatus, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      t(pt: 'Status de Pagamento', en: 'Payment Status'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: corStatus.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: corStatus),
                  ),
                  child: Text(
                    textoStatus,
                    style: TextStyle(
                      color: corStatus,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentagem / 100,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: corStatus,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${percentagem.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValorInfo(
                  context,
                  t(pt: 'Total da Fatura', en: 'Invoice Total'),
                  totalFatura,
                  Colors.blue,
                  Icons.receipt,
                ),
                _buildValorInfo(
                  context,
                  t(pt: 'Valor Pago', en: 'Paid Amount'),
                  totalPago,
                  Colors.green,
                  Icons.check_circle_outline,
                ),
                _buildValorInfo(
                  context,
                  t(pt: 'Em Dívida', en: 'Outstanding'),
                  valorEmDivida,
                  valorEmDivida > 0 ? Colors.orange : Colors.grey,
                  Icons.pending_actions,
                ),
              ],
            ),
            if (pagamentos.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t(pt: 'Pagamentos Registados', en: 'Recorded Payments'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pagamentos.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompacto(
    BuildContext context,
    Color cor,
    IconData icon,
    String texto,
    double percentagem,
  ) {
    return Row(
      children: [
        Icon(icon, color: cor, size: 16),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            color: cor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percentagem / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(cor),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentagem.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildValorInfo(
    BuildContext context,
    String label,
    double valor,
    Color cor,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: cor),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '€${valor.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: cor,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
