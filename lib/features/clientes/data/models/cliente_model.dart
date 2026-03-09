import 'package:hive/hive.dart';
import '../../domain/entities/cliente.dart';

part 'cliente_model.g.dart';

@HiveType(typeId: 0)
class ClienteModel extends Cliente {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String nome;

  @HiveField(2)
  @override
  final String nif;

  @HiveField(3)
  @override
  final String email;

  @HiveField(4)
  @override
  final String telefone;

  @HiveField(5)
  @override
  final String morada;

  @HiveField(6)
  @override
  final DateTime dataCriacao;

  ClienteModel({
    required this.id,
    required this.nome,
    required this.nif,
    required this.email,
    required this.telefone,
    required this.morada,
    required this.dataCriacao,
  }) : super(
          id: id,
          nome: nome,
          nif: nif,
          email: email,
          telefone: telefone,
          morada: morada,
          dataCriacao: dataCriacao,
        );

  factory ClienteModel.fromEntity(Cliente cliente) {
    return ClienteModel(
      id: cliente.id,
      nome: cliente.nome,
      nif: cliente.nif,
      email: cliente.email,
      telefone: cliente.telefone,
      morada: cliente.morada,
      dataCriacao: cliente.dataCriacao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nif': nif,
      'email': email,
      'telefone': telefone,
      'morada': morada,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'],
      nome: json['nome'],
      nif: json['nif'],
      email: json['email'],
      telefone: json['telefone'],
      morada: json['morada'],
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }
}
