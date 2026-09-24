// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressAdapter extends TypeAdapter<Progress> {
  @override
  final int typeId = 1;

  @override
  Progress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Progress(
      lessonId: fields[0] as String,
      completed: fields[1] as bool,
      completedAt: fields[2] as DateTime?,
      timesOpened: fields[3] as int,
      quizScore: fields[4] as int?,
      unlockedByReward: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Progress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.timesOpened)
      ..writeByte(4)
      ..write(obj.quizScore)
      ..writeByte(5)
      ..write(obj.unlockedByReward);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
