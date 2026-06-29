import 'dart:convert';
import '../../../../core/network/network_info.dart';
import '../../../todos/data/datasources/todos_local_data_source.dart';
import '../../../todos/data/models/todo_model.dart';
import '../../../todos/domain/repositories/todos_repository.dart';

class SyncManager {
  final NetworkInfo _networkInfo;
  final TodosLocalDataSource _localDataSource;
  final TodosRepository _todosRepository;

  SyncManager({
    required NetworkInfo networkInfo,
    required TodosLocalDataSource localDataSource,
    required TodosRepository todosRepository,
  })  : _networkInfo = networkInfo,
        _localDataSource = localDataSource,
        _todosRepository = todosRepository;

  Future<void> processSyncQueue() async {
    try {
      final queue = await _localDataSource.getSyncQueue();
      if (queue.isEmpty) return;

      final todos = <TodoModel>[];
      for (var item in queue) {
        if (item.action == 'save') {
          final todoJson = jsonDecode(item.payloadJson) as Map<String, dynamic>;
          todos.add(TodoModel.fromJson(todoJson));
        }
      }

      if (todos.isNotEmpty) {
        final entities = todos.map((m) => m.toEntity()).toList();
        await _todosRepository.syncTodos(entities);
        
        for (var item in queue) {
          await _localDataSource.removeFromSyncQueue(item.id);
        }
      }
    } catch (_) {}
  }
}
