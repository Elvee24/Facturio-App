import '../../../../shared/models/linha_fatura.dart';

class Fatura {
  final String id;
  final String numero;
  final DateTime data;
  final String clienteId;
  final String clienteNome;
  final List<LinhaFatura> linhas;
  final String estado; // rascunho, emitida, paga, cancelada

  Fatura({
    required this.id,
    required this.numero,
    required this.data,
    required this.clienteId,
    required this.clienteNome,
    required this.linhas,
    required this.estado,
  });

  double get subtotal => linhas.fold(0, (sum, linha) => sum + linha.subtotal);
  double get totalIva => linhas.fold(0, (sum, linha) => sum + linha.valorIva);
  double get total => linhas.fold(0, (sum, linha) => sum + linha.total);

  Fatura copyWith({
    String? id,
    String? numero,
    DateTime? data,
    String? clienteId,
    String? clienteNome,
    List<LinhaFatura>? linhas,
    String? estado,
  }) {
    return Fatura(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      data: data ?? this.data,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      linhas: linhas ?? this.linhas,
      estado: estado ?? this.estado,
    );
  }
}
