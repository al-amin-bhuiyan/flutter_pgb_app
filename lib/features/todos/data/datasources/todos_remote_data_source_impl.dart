import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
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
    try {
      final response = await _client.dio.get('/todos');

      if (response.statusCode == 200) {
        final dataMap = response.data as Map<String, dynamic>;
        final list = dataMap['data'] as List<dynamic>;
        return list
            .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveTodo(TodoModel todo) async {
    try {
      final response = await _client.dio.patch(
        '/todos/${todo.id}',
        data: {
          'is_completed': todo.isCompleted,
          'updated_at': todo.updatedAt.toIso8601String(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> syncTodos(List<TodoModel> todos) async {
    try {
      final response = await _client.dio.post(
        '/todos/sync',
        data: {
          'changes': todos
              .map((todo) => {
                    'todo_id': todo.id,
                    'is_completed': todo.isCompleted,
                    'updated_at': todo.updatedAt.toIso8601String(),
                  })
              .toList(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
