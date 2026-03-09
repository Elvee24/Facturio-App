import 'package:hive/hive.dart';
import '../../features/produtos/domain/entities/produto.dart';

part 'linha_fatura.g.dart';

@HiveType(typeId: 3)
class LinhaFatura {
  @HiveField(0)
  final String produtoId;

  @HiveField(1)
  final String produtoNome;

  @HiveField(2)
  final double quantidade;

  @HiveField(3)
  final double precoUnitario;

  @HiveField(4)
  final double desconto;

  @HiveField(5)
  final double iva;

  LinhaFatura({
    required this.produtoId,
    required this.produtoNome,
    required this.quantidade,
    required this.precoUnitario,
    required this.desconto,
    required this.iva,
  });

  factory LinhaFatura.fromProduto(Produto produto, double quantidade) {
    return LinhaFatura(
      produtoId: produto.id,
      produtoNome: produto.nome,
      quantidade: quantidade,
      precoUnitario: produto.preco,
      desconto: 0,
      iva: produto.iva,
    );
  }

  double get subtotal => quantidade * precoUnitario * (1 - desconto / 100);
  double get valorIva => subtotal * (iva / 100);
  double get total => subtotal + valorIva;

  LinhaFatura copyWith({
    String? produtoId,
    String? produtoNome,
    double? quantidade,
    double? precoUnitario,
    double? desconto,
    double? iva,
  }) {
    return LinhaFatura(
      produtoId: produtoId ?? this.produtoId,
      produtoNome: produtoNome ?? this.produtoNome,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      desconto: desconto ?? this.desconto,
      iva: iva ?? this.iva,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produtoId': produtoId,
      'produtoNome': produtoNome,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
      'desconto': desconto,
      'iva': iva,
    };
  }

  factory LinhaFatura.fromJson(Map<String, dynamic> json) {
    return LinhaFatura(
      produtoId: json['produtoId'],
      produtoNome: json['produtoNome'],
      quantidade: json['quantidade'].toDouble(),
      precoUnitario: json['precoUnitario'].toDouble(),
      desconto: json['desconto'].toDouble(),
      iva: json['iva'].toDouble(),
    );
  }
}
