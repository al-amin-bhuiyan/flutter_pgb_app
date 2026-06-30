import 'dart:convert';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../datasources/todos_local_data_source.dart';
import '../datasources/todos_remote_data_source.dart';
import '../models/todo_model.dart';
import '../../../sync/data/models/sync_queue_item_model.dart';

class TodosRepositoryImpl implements TodosRepository {
  final TodosRemoteDataSource _remoteDataSource;
  final TodosLocalDataSource _localDataSource;

  TodosRepositoryImpl({
    required TodosRemoteDataSource remoteDataSource,
    required TodosLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final remoteTodos = await _remoteDataSource.getTodos();
      await _localDataSource.cacheTodos(remoteTodos);
      return remoteTodos.map((model) => model.toEntity()).toList();
    } catch (_) {
      final localTodos = await _localDataSource.getCachedTodos();
      if (localTodos.isNotEmpty) {
        return localTodos.map((model) => model.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<void> saveTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    try {
      await _remoteDataSource.saveTodo(model);
      await _localDataSource.cacheTodo(model);
    } catch (_) {
      await _localDataSource.cacheTodo(model);
      final item = SyncQueueItemModel(
        id: todo.id,
        action: 'save',
        payloadJson: jsonEncode(model.toJson()),
        createdAt: DateTime.now(),
      );
      await _localDataSource.addToSyncQueue(item);
    }
  }

  @override
  Future<void> syncTodos(List<Todo> todos) async {
    final models = todos.map((e) => TodoModel.fromEntity(e)).toList();
    await _remoteDataSource.syncTodos(models);
    for (var model in models) {
      await _localDataSource.cacheTodo(model);
    }
  }

  @override
  Future<int> getPendingSyncCount() async {
    final queue = await _localDataSource.getSyncQueue();
    return queue.length;
  }
}
