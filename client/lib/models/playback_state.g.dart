// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaybackStateAdapter extends TypeAdapter<PlaybackState> {
  @override
  final int typeId = 1;

  @override
  PlaybackState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaybackState(
      itemId: fields[0] as String,
      serverId: fields[1] as String,
      positionTicks: fields[2] as int,
      lastUpdated: fields[3] as DateTime,
      durationTicks: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlaybackState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.positionTicks)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.durationTicks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
