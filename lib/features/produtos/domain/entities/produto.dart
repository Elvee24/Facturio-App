class Produto {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final double iva; // 23, 13, 6, 0
  final String unidade; // un, kg, m, etc
  final int stock;

  Produto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.iva,
    required this.unidade,
    required this.stock,
  });

  Produto copyWith({
    String? id,
    String? nome,
    String? descricao,
    double? preco,
    double? iva,
    String? unidade,
    int? stock,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      iva: iva ?? this.iva,
      unidade: unidade ?? this.unidade,
      stock: stock ?? this.stock,
    );
  }

  double get precoComIva => preco * (1 + iva / 100);
}
