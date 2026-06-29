import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'sync_queue_item_model.g.dart';

@HiveType(typeId: 3)
class SyncQueueItemModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String action;

  @HiveField(2)
  final String payloadJson;

  @HiveField(3)
  final DateTime createdAt;

  const SyncQueueItemModel({
    required this.id,
    required this.action,
    required this.payloadJson,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, action, payloadJson, createdAt];
}
