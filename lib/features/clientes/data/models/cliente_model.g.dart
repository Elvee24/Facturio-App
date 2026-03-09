// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClienteModelAdapter extends TypeAdapter<ClienteModel> {
  @override
  final int typeId = 0;

  @override
  ClienteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClienteModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      nif: fields[2] as String,
      email: fields[3] as String,
      telefone: fields[4] as String,
      morada: fields[5] as String,
      dataCriacao: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClienteModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.nif)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.telefone)
      ..writeByte(5)
      ..write(obj.morada)
      ..writeByte(6)
      ..write(obj.dataCriacao);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClienteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
