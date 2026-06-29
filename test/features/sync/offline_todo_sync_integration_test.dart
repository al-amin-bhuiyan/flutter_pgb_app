import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/core/network/network_info.dart';
import 'package:flutter_pgb_app/features/sync/data/services/sync_manager.dart';
import 'package:flutter_pgb_app/features/todos/data/datasources/todos_local_data_source.dart';
import 'package:flutter_pgb_app/features/todos/data/models/todo_model.dart';
import 'package:flutter_pgb_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:flutter_pgb_app/features/sync/data/models/sync_queue_item_model.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockTodosLocalDataSource extends Mock implements TodosLocalDataSource {}
class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  late MockNetworkInfo mockNetworkInfo;
  late MockTodosLocalDataSource mockLocalDataSource;
  late MockTodosRepository mockTodosRepository;
  late SyncManager syncManager;
  late StreamController<bool> connectivityController;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockLocalDataSource = MockTodosLocalDataSource();
    mockTodosRepository = MockTodosRepository();
    connectivityController = StreamController<bool>.broadcast();

    when(() => mockNetworkInfo.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);

    syncManager = SyncManager(
      networkInfo: mockNetworkInfo,
      localDataSource: mockLocalDataSource,
      todosRepository: mockTodosRepository,
    );
  });

  tearDown(() {
    connectivityController.close();
    syncManager.dispose();
  });

  final tTodoModel1 = TodoModel(
    id: '1',
    title: 'Task 1',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 29, 10, 0, 0),
  );

  final tTodoModel2Old = TodoModel(
    id: '2',
    title: 'Task 2',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 29, 10, 0, 0),
  );

  final tTodoModel2New = TodoModel(
    id: '2',
    title: 'Task 2 Updated',
    isCompleted: true,
    updatedAt: DateTime(2026, 6, 29, 10, 15, 0),
  );

  final tSyncQueue = [
    SyncQueueItemModel(
      id: '1',
      action: 'save',
      payloadJson: '{"id":"1","title":"Task 1","is_completed":false,"updated_at":"2026-06-29T10:00:00.000"}',
      createdAt: DateTime(2026, 6, 29, 10, 0, 0),
    ),
    SyncQueueItemModel(
      id: '2',
      action: 'save',
      payloadJson: '{"id":"2","title":"Task 2","is_completed":false,"updated_at":"2026-06-29T10:00:00.000"}',
      createdAt: DateTime(2026, 6, 29, 10, 0, 0),
    ),
    SyncQueueItemModel(
      id: '2',
      action: 'save',
      payloadJson: '{"id":"2","title":"Task 2 Updated","is_completed":true,"updated_at":"2026-06-29T10:15:00.000"}',
      createdAt: DateTime(2026, 6, 29, 10, 15, 0),
    ),
  ];

  group('SyncManager Integration', () {
    test('should resolve conflicts and trigger sync on network reconnection', () async {
      // 1. Setup mocks
      when(() => mockLocalDataSource.getSyncQueue()).thenAnswer((_) async => tSyncQueue);
      when(() => mockTodosRepository.syncTodos(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.removeFromSyncQueue(any())).thenAnswer((_) async => {});

      // 2. Initialize sync manager (starts listening)
      syncManager.initialize();

      // 3. Emit network reconnection event
      connectivityController.add(true);

      // Wait for stream event loop to flush
      await Future.delayed(Duration.zero);

      // 4. Verify that repository sync was triggered with only latest changes (Task 1 and Task 2 New)
      final captured = verify(() => mockTodosRepository.syncTodos(captureAny())).captured.first as List;
      expect(captured.length, 2);
      expect(captured.any((t) => t.id == '1'), true);
      expect(captured.any((t) => t.id == '2' && t.isCompleted == true && t.title == 'Task 2 Updated'), true);

      // 5. Verify all queue entries were deleted
      verify(() => mockLocalDataSource.removeFromSyncQueue('1')).called(1);
      verify(() => mockLocalDataSource.removeFromSyncQueue('2')).called(2);
    });
  });
}
