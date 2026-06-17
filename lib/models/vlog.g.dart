// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vlog.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VlogAdapter extends TypeAdapter<Vlog> {
  @override
  final int typeId = 0;

  @override
  Vlog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vlog(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      status: fields[4] as String,
      uploadDate: fields[5] as DateTime,
      isFavorite: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Vlog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.uploadDate)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VlogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
