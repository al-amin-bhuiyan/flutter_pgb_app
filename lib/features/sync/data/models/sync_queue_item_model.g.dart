// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueItemModelAdapter extends TypeAdapter<SyncQueueItemModel> {
  @override
  final typeId = 3;

  @override
  SyncQueueItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItemModel(
      id: fields[0] as String,
      action: fields[1] as String,
      payloadJson: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItemModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.payloadJson)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
