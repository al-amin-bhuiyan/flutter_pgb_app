import '../entities/todo.dart';

abstract class TodosRepository {
  Future<List<Todo>> getTodos();

  Future<void> saveTodo(Todo todo);

  Future<void> syncTodos(List<Todo> todos);

  Future<int> getPendingSyncCount();
}
