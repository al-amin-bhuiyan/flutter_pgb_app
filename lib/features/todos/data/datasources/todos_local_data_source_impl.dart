import '../../../../core/database/hive_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../sync/data/models/sync_queue_item_model.dart';
import '../models/todo_model.dart';
import 'todos_local_data_source.dart';

class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  final HiveService _hiveService;

  TodosLocalDataSourceImpl({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    try {
      final box = _hiveService.getBox<TodoModel>('todos_box');
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    try {
      final box = _hiveService.getBox<TodoModel>('todos_box');
      await box.clear();
      final map = {for (var t in todos) t.id: t};
      await box.putAll(map);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    try {
      final box = _hiveService.getBox<TodoModel>('todos_box');
      await box.put(todo.id, todo);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> addToSyncQueue(SyncQueueItemModel item) async {
    try {
      final box = _hiveService.getBox<SyncQueueItemModel>('sync_queue_box');
      await box.put(item.id, item);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<SyncQueueItemModel>> getSyncQueue() async {
    try {
      final box = _hiveService.getBox<SyncQueueItemModel>('sync_queue_box');
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> removeFromSyncQueue(String id) async {
    try {
      final box = _hiveService.getBox<SyncQueueItemModel>('sync_queue_box');
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearSyncQueue() async {
    try {
      final box = _hiveService.getBox<SyncQueueItemModel>('sync_queue_box');
      await box.clear();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
