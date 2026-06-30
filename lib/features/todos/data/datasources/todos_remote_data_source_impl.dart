import '../../../../core/network/dio_client.dart';
import '../models/todo_model.dart';
import 'todos_remote_data_source.dart';

class TodosRemoteDataSourceImpl implements TodosRemoteDataSource {
  final DioClient _client;

  TodosRemoteDataSourceImpl({
    required DioClient client,
  }) : _client = client;

  @override
  Future<List<TodoModel>> getTodos() async {
    return _client.getList<TodoModel>(
      path: '/todos',
      fromJson: TodoModel.fromJson,
    );
  }

  @override
  Future<void> saveTodo(TodoModel todo) async {
    await _client.patch(
      path: '/todos/${todo.id}',
      data: {
        'is_completed': todo.isCompleted,
        'updated_at': todo.updatedAt.toIso8601String(),
      },
    );
  }

  @override
  Future<void> syncTodos(List<TodoModel> todos) async {
    await _client.post<dynamic>(
      path: '/todos/sync',
      data: {
        'changes': todos
            .map((todo) => {
                  'todo_id': todo.id,
                  'is_completed': todo.isCompleted,
                  'updated_at': todo.updatedAt.toIso8601String(),
                })
            .toList(),
      },
      fromJson: (data) => data,
    );
  }
}
