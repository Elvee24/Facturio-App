// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linha_fatura.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinhaFaturaAdapter extends TypeAdapter<LinhaFatura> {
  @override
  final int typeId = 3;

  @override
  LinhaFatura read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LinhaFatura(
      produtoId: fields[0] as String,
      produtoNome: fields[1] as String,
      quantidade: fields[2] as double,
      precoUnitario: fields[3] as double,
      desconto: fields[4] as double,
      iva: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LinhaFatura obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.produtoId)
      ..writeByte(1)
      ..write(obj.produtoNome)
      ..writeByte(2)
      ..write(obj.quantidade)
      ..writeByte(3)
      ..write(obj.precoUnitario)
      ..writeByte(4)
      ..write(obj.desconto)
      ..writeByte(5)
      ..write(obj.iva);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinhaFaturaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
