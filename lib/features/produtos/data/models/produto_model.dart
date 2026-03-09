import 'package:hive/hive.dart';
import '../../domain/entities/produto.dart';

part 'produto_model.g.dart';

@HiveType(typeId: 1)
class ProdutoModel extends Produto {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String nome;

  @HiveField(2)
  @override
  final String descricao;

  @HiveField(3)
  @override
  final double preco;

  @HiveField(4)
  @override
  final double iva;

  @HiveField(5)
  @override
  final String unidade;

  @HiveField(6)
  @override
  final int stock;

  ProdutoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.iva,
    required this.unidade,
    required this.stock,
  }) : super(
          id: id,
          nome: nome,
          descricao: descricao,
          preco: preco,
          iva: iva,
          unidade: unidade,
          stock: stock,
        );

  factory ProdutoModel.fromEntity(Produto produto) {
    return ProdutoModel(
      id: produto.id,
      nome: produto.nome,
      descricao: produto.descricao,
      preco: produto.preco,
      iva: produto.iva,
      unidade: produto.unidade,
      stock: produto.stock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'iva': iva,
      'unidade': unidade,
      'stock': stock,
    };
  }

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: json['preco'].toDouble(),
      iva: json['iva'].toDouble(),
      unidade: json['unidade'],
      stock: json['stock'],
    );
  }
}
