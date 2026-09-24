// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_timer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnlockTimerAdapter extends TypeAdapter<UnlockTimer> {
  @override
  final int typeId = 5;

  @override
  UnlockTimer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnlockTimer(
      lessonId: fields[0] as String,
      expiresAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UnlockTimer obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockTimerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
