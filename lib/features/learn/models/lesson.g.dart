// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 0;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      id: fields[0] as String,
      module: fields[1] as String,
      level: fields[2] as String,
      order: fields[3] as int,
      title: fields[4] as String,
      summary: fields[5] as String,
      explanation: fields[6] as String,
      codeExample: fields[7] as String,
      keyPoints: (fields[8] as List).cast<String>(),
      starterFiles: (fields[9] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.module)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.summary)
      ..writeByte(6)
      ..write(obj.explanation)
      ..writeByte(7)
      ..write(obj.codeExample)
      ..writeByte(8)
      ..write(obj.keyPoints)
      ..writeByte(9)
      ..write(obj.starterFiles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
