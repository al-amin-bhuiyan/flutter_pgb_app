import '../../../sync/data/models/sync_queue_item_model.dart';
import '../models/todo_model.dart';

abstract class TodosLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> cacheTodo(TodoModel todo);

  Future<void> addToSyncQueue(SyncQueueItemModel item);
  Future<List<SyncQueueItemModel>> getSyncQueue();
  Future<void> removeFromSyncQueue(String id);
  Future<void> clearSyncQueue();
}
