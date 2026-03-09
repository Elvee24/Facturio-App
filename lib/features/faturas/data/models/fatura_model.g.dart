// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fatura_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FaturaModelAdapter extends TypeAdapter<FaturaModel> {
  @override
  final int typeId = 2;

  @override
  FaturaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FaturaModel(
      id: fields[0] as String,
      numero: fields[1] as String,
      data: fields[2] as DateTime,
      clienteId: fields[3] as String,
      clienteNome: fields[4] as String,
      linhas: (fields[5] as List).cast<LinhaFatura>(),
      estado: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FaturaModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.numero)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.clienteId)
      ..writeByte(4)
      ..write(obj.clienteNome)
      ..writeByte(5)
      ..write(obj.linhas)
      ..writeByte(6)
      ..write(obj.estado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaturaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
