// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_attempt.dart';

class QuizAttemptAdapter extends TypeAdapter<QuizAttempt> {
  @override
  final int typeId = 4;

  @override
  QuizAttempt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizAttempt(
      id: fields[0] as String,
      subject: fields[1] as String,
      level: fields[2] as String,
      correct: fields[3] as int,
      total: fields[4] as int,
      takenAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizAttempt obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.correct)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.takenAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAttemptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
