// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovementHistoryAdapter extends TypeAdapter<MovementHistory> {
  @override
  final int typeId = 1;

  @override
  MovementHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovementHistory(
      id: fields[0] as String?,
      geofenceId: fields[1] as String,
      geofenceName: fields[2] as String,
      timestamp: fields[3] as DateTime,
      latitude: fields[4] as double,
      longitude: fields[5] as double,
      isEntering: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MovementHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.geofenceId)
      ..writeByte(2)
      ..write(obj.geofenceName)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.isEntering);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
