import '../models/todo_model.dart';

abstract class TodosRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> saveTodo(TodoModel todo);
  Future<void> syncTodos(List<TodoModel> todos);
}
