import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_remote_data_source.dart';
import 'package:flutter_pgb_app/features/todos/data/models/todo_model.dart';
import 'package:flutter_pgb_app/features/todos/data/repositories/todos_repository_impl.dart';
import 'package:flutter_pgb_app/features/todos/domain/entities/todo.dart';
import 'package:flutter_pgb_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:flutter_pgb_app/features/sync/data/models/sync_queue_item_model.dart';

class MockTodosRemoteDataSource extends Mock implements TodosRemoteDataSource {}
class MockTodosLocalDataSource extends Mock implements TodosLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      TodoModel(
        id: 'dummy',
        title: 'dummy',
        isCompleted: false,
        updatedAt: DateTime(2026),
      ),
    );
    registerFallbackValue(
      SyncQueueItemModel(
        id: 'dummy',
        action: 'dummy',
        payloadJson: 'dummy',
        createdAt: DateTime(2026),
      ),
    );
  });

  late MockTodosRemoteDataSource mockRemoteDataSource;
  late MockTodosLocalDataSource mockLocalDataSource;
  late TodosRepository repository;

  setUp(() {
    mockRemoteDataSource = MockTodosRemoteDataSource();
    mockLocalDataSource = MockTodosLocalDataSource();
    repository = TodosRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tTodo = Todo(
    id: '1',
    title: 'Test',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 29),
  );

  final tTodoModel = TodoModel(
    id: '1',
    title: 'Test',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 29),
  );

  group('getTodos', () {
    test('should return remote todos and cache them when network call is successful', () async {
      when(() => mockRemoteDataSource.getTodos()).thenAnswer((_) async => [tTodoModel]);
      when(() => mockLocalDataSource.cacheTodos(any())).thenAnswer((_) async => {});

      final result = await repository.getTodos();

      expect(result, [tTodo]);
      verify(() => mockRemoteDataSource.getTodos()).called(1);
      verify(() => mockLocalDataSource.cacheTodos([tTodoModel])).called(1);
    });

    test('should fallback to local cache when network call fails', () async {
      when(() => mockRemoteDataSource.getTodos()).thenThrow(Exception('Server error'));
      when(() => mockLocalDataSource.getCachedTodos()).thenAnswer((_) async => [tTodoModel]);

      final result = await repository.getTodos();

      expect(result, [tTodo]);
      verify(() => mockRemoteDataSource.getTodos()).called(1);
      verify(() => mockLocalDataSource.getCachedTodos()).called(1);
    });
  });

  group('saveTodo', () {
    test('should save todo to remote and local cache when network is online', () async {
      when(() => mockRemoteDataSource.saveTodo(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.cacheTodo(any())).thenAnswer((_) async => {});

      await repository.saveTodo(tTodo);

      verify(() => mockRemoteDataSource.saveTodo(any())).called(1);
      verify(() => mockLocalDataSource.cacheTodo(any())).called(1);
    });

    test('should cache locally and add transaction item to sync queue when network is offline', () async {
      when(() => mockRemoteDataSource.saveTodo(any())).thenThrow(Exception('No internet'));
      when(() => mockLocalDataSource.cacheTodo(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.addToSyncQueue(any())).thenAnswer((_) async => {});

      await repository.saveTodo(tTodo);

      verify(() => mockLocalDataSource.cacheTodo(any())).called(1);
      verify(() => mockLocalDataSource.addToSyncQueue(any())).called(1);
    });
  });

  group('syncTodos', () {
    test('should sync all checklist updates to remote API and write cache', () async {
      when(() => mockRemoteDataSource.syncTodos(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.cacheTodo(any())).thenAnswer((_) async => {});

      await repository.syncTodos([tTodo]);

      verify(() => mockRemoteDataSource.syncTodos(any())).called(1);
      verify(() => mockLocalDataSource.cacheTodo(any())).called(1);
    });
  });
}
