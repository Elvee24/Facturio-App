import '../../features/faturas/domain/entities/fatura.dart';
import '../../shared/models/pagamento.dart';

class ResumoFinanceiroPagamentos {
  final double totalFaturado;
  final double totalRecebido;
  final double totalEmDivida;
  final int faturasCompletamentePagas;
  final int faturasParcialmentePagas;
  final int faturasNaoPagas;

  const ResumoFinanceiroPagamentos({
    required this.totalFaturado,
    required this.totalRecebido,
    required this.totalEmDivida,
    required this.faturasCompletamentePagas,
    required this.faturasParcialmentePagas,
    required this.faturasNaoPagas,
  });

  double get percentagemRecebida {
    if (totalFaturado <= 0) return 0;
    return (totalRecebido / totalFaturado) * 100;
  }
}

/// Serviço responsável pela lógica de negócio de pagamentos.
/// 
/// Calcula valores, valida pagamentos e fornece análises financeiras.
class PagamentosService {
  /// Calcula o total já pago numa fatura (soma de todos os pagamentos)
  static double calcularTotalPago(List<Pagamento> pagamentos) {
    if (pagamentos.isEmpty) return 0.0;
    return pagamentos.fold<double>(0, (sum, pag) => sum + pag.valor);
  }

  /// Calcula o valor em dívida de uma fatura
  /// 
  /// Retorna o total da fatura menos os pagamentos efetuados
  static double calcularValorEmDivida(Fatura fatura, List<Pagamento> pagamentos) {
    final totalFatura = fatura.totalComRetencao;
    final totalPago = calcularTotalPago(pagamentos);
    final divida = totalFatura - totalPago;
    return divida < 0 ? 0 : divida; // Não retorna valores negativos
  }

  /// Verifica se a fatura está completamente paga
  static bool estaCompletamentePaga(Fatura fatura, List<Pagamento> pagamentos) {
    final valorEmDivida = calcularValorEmDivida(fatura, pagamentos);
    return valorEmDivida <= 0.01; // Tolerância de 1 cêntimo para erros de arredondamento
  }

  /// Verifica se a fatura está parcialmente paga
  static bool estaParcialmentePaga(Fatura fatura, List<Pagamento> pagamentos) {
    final totalPago = calcularTotalPago(pagamentos);
    return totalPago > 0 && !estaCompletamentePaga(fatura, pagamentos);
  }

  /// Valida se um pagamento pode ser registado
  /// 
  /// Retorna mensagem de erro se inválido, ou null se válido
  static String? validarPagamento({
    required Fatura fatura,
    required List<Pagamento> pagamentosExistentes,
    required double valorNovoPagamento,
  }) {
    if (valorNovoPagamento <= 0) {
      return 'O valor do pagamento deve ser positivo.';
    }

    final valorEmDivida = calcularValorEmDivida(fatura, pagamentosExistentes);
    
    if (valorNovoPagamento > valorEmDivida + 0.01) {
      return 'O valor do pagamento (€${valorNovoPagamento.toStringAsFixed(2)}) '
          'ultrapassa a dívida restante (€${valorEmDivida.toStringAsFixed(2)}).';
    }

    return null; // Válido
  }

  /// Calcula a percentagem paga de uma fatura
  /// 
  /// Retorna valor entre 0.0 e 100.0
  static double calcularPercentagemPaga(Fatura fatura, List<Pagamento> pagamentos) {
    final totalFatura = fatura.totalComRetencao;
    if (totalFatura == 0) return 100.0;
    
    final totalPago = calcularTotalPago(pagamentos);
    final percentagem = (totalPago / totalFatura) * 100;
    
    return percentagem > 100 ? 100.0 : percentagem;
  }

  /// Retorna status textual do pagamento da fatura
  static String obterStatusPagamento(Fatura fatura, List<Pagamento> pagamentos) {
    if (pagamentos.isEmpty) {
      return 'Não Paga';
    }

    if (estaCompletamentePaga(fatura, pagamentos)) {
      return 'Paga';
    }

    if (estaParcialmentePaga(fatura, pagamentos)) {
      final percentagem = calcularPercentagemPaga(fatura, pagamentos);
      return 'Parcialmente Paga (${percentagem.toStringAsFixed(0)}%)';
    }

    return 'Não Paga';
  }

  /// Gera resumo financeiro de pagamentos
  static ResumoFinanceiroPagamentos gerarResumoFinanceiro({
    required List<Fatura> faturas,
    required Map<String, List<Pagamento>> pagamentosPorFatura,
  }) {
    double totalFaturado = 0;
    double totalRecebido = 0;
    double totalEmDivida = 0;
    int faturasCompletamentePagas = 0;
    int faturasParcialmentePagas = 0;
    int faturasNaoPagas = 0;

    for (final fatura in faturas) {
      if (fatura.estado == 'cancelada') continue;

      final valorFatura = fatura.totalComRetencao;
      totalFaturado += valorFatura;

      final pagamentos = pagamentosPorFatura[fatura.id] ?? [];
      final valorPago = calcularTotalPago(pagamentos);
      totalRecebido += valorPago;

      final valorDivida = calcularValorEmDivida(fatura, pagamentos);
      totalEmDivida += valorDivida;

      if (estaCompletamentePaga(fatura, pagamentos)) {
        faturasCompletamentePagas++;
      } else if (estaParcialmentePaga(fatura, pagamentos)) {
        faturasParcialmentePagas++;
      } else {
        faturasNaoPagas++;
      }
    }

    return ResumoFinanceiroPagamentos(
      totalFaturado: totalFaturado,
      totalRecebido: totalRecebido,
      totalEmDivida: totalEmDivida,
      faturasCompletamentePagas: faturasCompletamentePagas,
      faturasParcialmentePagas: faturasParcialmentePagas,
      faturasNaoPagas: faturasNaoPagas,
    );
  }

  /// Agrupa pagamentos por meio de pagamento
  static Map<String, double> agruparPorMeioPagamento(List<Pagamento> pagamentos) {
    final Map<String, double> totais = {};
    
    for (final pag in pagamentos) {
      totais[pag.meioPagamento] = (totais[pag.meioPagamento] ?? 0) + pag.valor;
    }

    return totais;
  }

  /// Filtra pagamentos por período
  static List<Pagamento> filtrarPorPeriodo(
    List<Pagamento> pagamentos,
    DateTime inicio,
    DateTime fim,
  ) {
    return pagamentos.where((pag) {
      return pag.dataPagamento.isAfter(inicio.subtract(const Duration(days: 1))) &&
          pag.dataPagamento.isBefore(fim.add(const Duration(days: 1)));
    }).toList();
  }

  /// Ordena pagamentos por data (mais recente primeiro)
  static List<Pagamento> ordenarPorDataDecrescente(List<Pagamento> pagamentos) {
    final lista = List<Pagamento>.from(pagamentos);
    lista.sort((a, b) => b.dataPagamento.compareTo(a.dataPagamento));
    return lista;
  }
}
