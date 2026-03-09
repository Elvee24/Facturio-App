// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProdutoModelAdapter extends TypeAdapter<ProdutoModel> {
  @override
  final int typeId = 1;

  @override
  ProdutoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProdutoModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      descricao: fields[2] as String,
      preco: fields[3] as double,
      iva: fields[4] as double,
      unidade: fields[5] as String,
      stock: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProdutoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descricao)
      ..writeByte(3)
      ..write(obj.preco)
      ..writeByte(4)
      ..write(obj.iva)
      ..writeByte(5)
      ..write(obj.unidade)
      ..writeByte(6)
      ..write(obj.stock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdutoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
