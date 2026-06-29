import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pgb_app/core/network/dio_client.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_remote_data_source.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_remote_data_source_impl.dart';
import 'package:flutter_pgb_app/features/todos/data/models/todo_model.dart';
import 'package:flutter_pgb_app/core/error/exceptions.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late TodosRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = TodosRemoteDataSourceImpl(client: mockDioClient);
  });

  final tTodoModel = TodoModel(
    id: '1',
    title: 'Sync Task',
    isCompleted: true,
    updatedAt: DateTime(2026, 6, 29),
  );

  final tTodoJson = {
    'id': '1',
    'title': 'Sync Task',
    'is_completed': true,
    'updated_at': '2026-06-29T00:00:00.000',
  };

  group('getTodos', () {
    test('should return list of TodoModel when status code is 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/todos'),
            data: [tTodoJson],
            statusCode: 200,
          ));

      final result = await dataSource.getTodos();

      expect(result.first.id, tTodoModel.id);
      expect(result.first.title, tTodoModel.title);
      expect(result.first.isCompleted, tTodoModel.isCompleted);
    });

    test('should throw ServerException when status code is not 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/todos'),
            statusCode: 500,
          ));

      final call = dataSource.getTodos();

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('saveTodo', () {
    test('should complete normally when response is 200 or 204', () async {
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/todos/1'),
            statusCode: 200,
          ));

      await dataSource.saveTodo(tTodoModel);

      verify(() => mockDio.patch('/todos/1', data: {
            'is_completed': true,
            'updated_at': '2026-06-29T00:00:00.000',
          })).called(1);
    });

    test('should throw ServerException when API patch fails', () async {
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/todos/1'),
            statusCode: 400,
          ));

      final call = dataSource.saveTodo(tTodoModel);

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('syncTodos', () {
    test('should complete normally when sync is successful', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/todos/sync'),
            statusCode: 200,
          ));

      await dataSource.syncTodos([tTodoModel]);

      verify(() => mockDio.post('/todos/sync', data: {
            'changes': [
              {
                'todo_id': '1',
                'is_completed': true,
                'updated_at': '2026-06-29T00:00:00.000',
              }
            ]
          })).called(1);
    });

    test('should throw ServerException when sync fails', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/todos/sync'),
            statusCode: 500,
          ));

      final call = dataSource.syncTodos([tTodoModel]);

      expect(call, throwsA(isA<ServerException>()));
    });
  });
}
