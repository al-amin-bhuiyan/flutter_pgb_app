import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_pgb_app/core/database/hive_service.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_local_data_source_impl.dart';
import 'package:flutter_pgb_app/features/todos/data/models/todo_model.dart';
import 'package:flutter_pgb_app/features/sync/data/models/sync_queue_item_model.dart';
import 'package:flutter_pgb_app/core/error/exceptions.dart';

class MockHiveService extends Mock implements HiveService {}
class MockTodoHiveBox extends Mock implements Box<TodoModel> {}
class MockSyncHiveBox extends Mock implements Box<SyncQueueItemModel> {}

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

  late MockHiveService mockHiveService;
  late MockTodoHiveBox mockTodoHiveBox;
  late MockSyncHiveBox mockSyncHiveBox;
  late TodosLocalDataSource dataSource;

  setUp(() {
    mockHiveService = MockHiveService();
    mockTodoHiveBox = MockTodoHiveBox();
    mockSyncHiveBox = MockSyncHiveBox();
    dataSource = TodosLocalDataSourceImpl(hiveService: mockHiveService);
  });

  final tTodoModel = TodoModel(
    id: '1',
    title: 'Test Task',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 29),
  );

  final tSyncItem = SyncQueueItemModel(
    id: '1',
    action: 'save',
    payloadJson: '{}',
    createdAt: DateTime(2026, 6, 29),
  );

  group('getCachedTodos', () {
    test('should return list of cached todos from Hive box', () async {
      when(() => mockHiveService.getBox<TodoModel>('todos_box')).thenReturn(mockTodoHiveBox);
      when(() => mockTodoHiveBox.values).thenReturn([tTodoModel]);

      final result = await dataSource.getCachedTodos();

      expect(result, [tTodoModel]);
      verify(() => mockHiveService.getBox<TodoModel>('todos_box')).called(1);
    });

    test('should throw CacheException when Hive throws an error', () async {
      when(() => mockHiveService.getBox<TodoModel>('todos_box')).thenThrow(Exception('Hive error'));

      final call = dataSource.getCachedTodos();

      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('cacheTodos', () {
    test('should clear and batch insert todos in Hive box', () async {
      when(() => mockHiveService.getBox<TodoModel>('todos_box')).thenReturn(mockTodoHiveBox);
      when(() => mockTodoHiveBox.clear()).thenAnswer((_) async => 0);
      when(() => mockTodoHiveBox.putAll(any())).thenAnswer((_) async => {});

      await dataSource.cacheTodos([tTodoModel]);

      verify(() => mockTodoHiveBox.clear()).called(1);
      verify(() => mockTodoHiveBox.putAll({'1': tTodoModel})).called(1);
    });
  });

  group('cacheTodo', () {
    test('should put single todo in Hive box', () async {
      when(() => mockHiveService.getBox<TodoModel>('todos_box')).thenReturn(mockTodoHiveBox);
      when(() => mockTodoHiveBox.put(any(), any())).thenAnswer((_) async => {});

      await dataSource.cacheTodo(tTodoModel);

      verify(() => mockTodoHiveBox.put('1', tTodoModel)).called(1);
    });
  });

  group('addToSyncQueue', () {
    test('should put item in sync queue Hive box', () async {
      when(() => mockHiveService.getBox<SyncQueueItemModel>('sync_queue_box')).thenReturn(mockSyncHiveBox);
      when(() => mockSyncHiveBox.put(any(), any())).thenAnswer((_) async => {});

      await dataSource.addToSyncQueue(tSyncItem);

      verify(() => mockSyncHiveBox.put('1', tSyncItem)).called(1);
    });
  });

  group('getSyncQueue', () {
    test('should return list of sync items from Hive box', () async {
      when(() => mockHiveService.getBox<SyncQueueItemModel>('sync_queue_box')).thenReturn(mockSyncHiveBox);
      when(() => mockSyncHiveBox.values).thenReturn([tSyncItem]);

      final result = await dataSource.getSyncQueue();

      expect(result, [tSyncItem]);
    });
  });

  group('removeFromSyncQueue', () {
    test('should delete item from Hive box by id', () async {
      when(() => mockHiveService.getBox<SyncQueueItemModel>('sync_queue_box')).thenReturn(mockSyncHiveBox);
      when(() => mockSyncHiveBox.delete(any())).thenAnswer((_) async => {});

      await dataSource.removeFromSyncQueue('1');

      verify(() => mockSyncHiveBox.delete('1')).called(1);
    });
  });

  group('clearSyncQueue', () {
    test('should clear Hive box', () async {
      when(() => mockHiveService.getBox<SyncQueueItemModel>('sync_queue_box')).thenReturn(mockSyncHiveBox);
      when(() => mockSyncHiveBox.clear()).thenAnswer((_) async => 0);

      await dataSource.clearSyncQueue();

      verify(() => mockSyncHiveBox.clear()).called(1);
    });
  });
}
