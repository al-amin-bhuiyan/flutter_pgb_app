// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence_location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeofenceLocationModelAdapter extends TypeAdapter<GeofenceLocationModel> {
  @override
  final typeId = 1;

  @override
  GeofenceLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeofenceLocationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      latitude: (fields[2] as num).toDouble(),
      longitude: (fields[3] as num).toDouble(),
      radius: (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, GeofenceLocationModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.radius);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeofenceLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
