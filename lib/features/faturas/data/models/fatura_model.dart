import 'package:hive/hive.dart';
import '../../../../shared/models/linha_fatura.dart';
import '../../domain/entities/fatura.dart';

part 'fatura_model.g.dart';

@HiveType(typeId: 2)
class FaturaModel extends Fatura {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String numero;

  @HiveField(2)
  @override
  final DateTime data;

  @HiveField(3)
  @override
  final String clienteId;

  @HiveField(4)
  @override
  final String clienteNome;

  @HiveField(5)
  @override
  final List<LinhaFatura> linhas;

  @HiveField(6)
  @override
  final String estado;

  FaturaModel({
    required this.id,
    required this.numero,
    required this.data,
    required this.clienteId,
    required this.clienteNome,
    required this.linhas,
    required this.estado,
  }) : super(
          id: id,
          numero: numero,
          data: data,
          clienteId: clienteId,
          clienteNome: clienteNome,
          linhas: linhas,
          estado: estado,
        );

  factory FaturaModel.fromEntity(Fatura fatura) {
    return FaturaModel(
      id: fatura.id,
      numero: fatura.numero,
      data: fatura.data,
      clienteId: fatura.clienteId,
      clienteNome: fatura.clienteNome,
      linhas: fatura.linhas,
      estado: fatura.estado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'data': data.toIso8601String(),
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'linhas': linhas.map((l) => l.toJson()).toList(),
      'estado': estado,
    };
  }

  factory FaturaModel.fromJson(Map<String, dynamic> json) {
    return FaturaModel(
      id: json['id'],
      numero: json['numero'],
      data: DateTime.parse(json['data']),
      clienteId: json['clienteId'],
      clienteNome: json['clienteNome'],
      linhas: (json['linhas'] as List)
          .map((l) => LinhaFatura.fromJson(l))
          .toList(),
      estado: json['estado'],
    );
  }
}
