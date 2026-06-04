// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emby_server.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmbyServerAdapter extends TypeAdapter<EmbyServer> {
  @override
  final int typeId = 0;

  @override
  EmbyServer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmbyServer(
      id: fields[0] as String,
      name: fields[1] as String,
      url: fields[2] as String,
      apiKey: fields[3] as String?,
      username: fields[4] as String?,
      password: fields[5] as String?,
      lastConnected: fields[6] as DateTime?,
      isActive: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EmbyServer obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.apiKey)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.lastConnected)
      ..writeByte(7)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbyServerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
