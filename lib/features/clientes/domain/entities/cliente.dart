class Cliente {
  final String id;
  final String nome;
  final String nif;
  final String email;
  final String telefone;
  final String morada;
  final DateTime dataCriacao;

  Cliente({
    required this.id,
    required this.nome,
    required this.nif,
    required this.email,
    required this.telefone,
    required this.morada,
    required this.dataCriacao,
  });

  Cliente copyWith({
    String? id,
    String? nome,
    String? nif,
    String? email,
    String? telefone,
    String? morada,
    DateTime? dataCriacao,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nif: nif ?? this.nif,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      morada: morada ?? this.morada,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
