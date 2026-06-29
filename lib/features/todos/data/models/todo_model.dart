import 'package:hive_ce/hive.dart';
import '../../domain/entities/todo.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 2)
class TodoModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime updatedAt;

  const TodoModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.updatedAt,
  });

  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      updatedAt: entity.updatedAt,
    );
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: (json['id'] ?? json['todo_id']) as String,
      title: (json['title'] ?? '') as String,
      isCompleted: (json['is_completed'] ?? json['isCompleted'] ?? false) as bool,
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      isCompleted: isCompleted,
      updatedAt: updatedAt,
    );
  }
}
