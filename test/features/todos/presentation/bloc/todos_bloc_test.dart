import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pgb_app/core/network/network_info.dart';
import 'package:flutter_pgb_app/features/sync/data/services/sync_manager.dart';
import 'package:flutter_pgb_app/features/todos/domain/entities/todo.dart';
import 'package:flutter_pgb_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:flutter_pgb_app/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:flutter_pgb_app/features/todos/domain/usecases/save_todo_usecase.dart';
import 'package:flutter_pgb_app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:flutter_pgb_app/features/todos/presentation/bloc/todos_event.dart';
import 'package:flutter_pgb_app/features/todos/presentation/bloc/todos_state.dart';

class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}
class MockSaveTodoUseCase extends Mock implements SaveTodoUseCase {}
class MockTodosRepository extends Mock implements TodosRepository {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockSyncManager extends Mock implements SyncManager {}

void main() {
  late MockGetTodosUseCase mockGetTodosUseCase;
  late MockSaveTodoUseCase mockSaveTodoUseCase;
  late MockTodosRepository mockTodosRepository;
  late MockNetworkInfo mockNetworkInfo;
  late MockSyncManager mockSyncManager;
  late StreamController<bool> connectivityStreamController;
  late TodosBloc todosBloc;

  final tTodo = Todo(
    id: '1',
    title: 'Inspect boundary flags',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 30),
  );

  setUpAll(() {
    registerFallbackValue(Todo(id: '', title: '', isCompleted: false, updatedAt: DateTime.now()));
  });

  setUp(() {
    mockGetTodosUseCase = MockGetTodosUseCase();
    mockSaveTodoUseCase = MockSaveTodoUseCase();
    mockTodosRepository = MockTodosRepository();
    mockNetworkInfo = MockNetworkInfo();
    mockSyncManager = MockSyncManager();
    connectivityStreamController = StreamController<bool>.broadcast();

    when(() => mockNetworkInfo.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);

    todosBloc = TodosBloc(
      getTodosUseCase: mockGetTodosUseCase,
      saveTodoUseCase: mockSaveTodoUseCase,
      todosRepository: mockTodosRepository,
      networkInfo: mockNetworkInfo,
      syncManager: mockSyncManager,
    );
  });

  tearDown(() {
    todosBloc.close();
    connectivityStreamController.close();
  });

  test('initial state should be TodosInitial', () {
    expect(todosBloc.state, TodosInitial());
  });

  group('LoadTodosEvent', () {
    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodosLoaded] when data is loaded successfully (online)',
      build: () {
        when(() => mockGetTodosUseCase()).thenAnswer((_) async => [tTodo]);
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockTodosRepository.getPendingSyncCount()).thenAnswer((_) async => 0);
        return todosBloc;
      },
      act: (bloc) => bloc.add(LoadTodosEvent()),
      expect: () => [
        TodosLoading(),
        TodosLoaded(todos: [tTodo], isOffline: false, pendingSyncCount: 0),
      ],
      verify: (_) {
        verify(() => mockGetTodosUseCase()).called(1);
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockTodosRepository.getPendingSyncCount()).called(1);
      },
    );

    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodosLoaded] when data is loaded successfully (offline)',
      build: () {
        when(() => mockGetTodosUseCase()).thenAnswer((_) async => [tTodo]);
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockTodosRepository.getPendingSyncCount()).thenAnswer((_) async => 3);
        return todosBloc;
      },
      act: (bloc) => bloc.add(LoadTodosEvent()),
      expect: () => [
        TodosLoading(),
        TodosLoaded(todos: [tTodo], isOffline: true, pendingSyncCount: 3),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodosError] when loading fails',
      build: () {
        when(() => mockGetTodosUseCase()).thenThrow(Exception('Cache error'));
        return todosBloc;
      },
      act: (bloc) => bloc.add(LoadTodosEvent()),
      expect: () => [
        TodosLoading(),
        const TodosError(message: 'Exception: Cache error'),
      ],
    );
  });

  group('AddTodoEvent', () {
    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodoActionSuccess] when adding todo is successful',
      build: () {
        when(() => mockSaveTodoUseCase(any())).thenAnswer((_) async => {});
        return todosBloc;
      },
      act: (bloc) => bloc.add(const AddTodoEvent(title: 'New Task')),
      expect: () => [
        TodosLoading(),
        const TodoActionSuccess(message: 'Todo added successfully'),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodosError] when adding todo fails',
      build: () {
        when(() => mockSaveTodoUseCase(any())).thenThrow(Exception('Save error'));
        return todosBloc;
      },
      act: (bloc) => bloc.add(const AddTodoEvent(title: 'New Task')),
      expect: () => [
        TodosLoading(),
        const TodosError(message: 'Exception: Save error'),
      ],
    );
  });

  group('ToggleTodoStatusEvent', () {
    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodoActionSuccess] when status toggle is successful',
      build: () {
        when(() => mockSaveTodoUseCase(any())).thenAnswer((_) async => {});
        return todosBloc;
      },
      act: (bloc) => bloc.add(ToggleTodoStatusEvent(todo: tTodo)),
      expect: () => [
        TodosLoading(),
        const TodoActionSuccess(message: 'Task updated successfully'),
      ],
    );

    blocTest<TodosBloc, TodosState>(
      'should emit [TodosLoading, TodosError] when toggling fails',
      build: () {
        when(() => mockSaveTodoUseCase(any())).thenThrow(Exception('Update error'));
        return todosBloc;
      },
      act: (bloc) => bloc.add(ToggleTodoStatusEvent(todo: tTodo)),
      expect: () => [
        TodosLoading(),
        const TodosError(message: 'Exception: Update error'),
      ],
    );
  });

  group('ConnectivityChangedEvent', () {
    blocTest<TodosBloc, TodosState>(
      'should trigger processSyncQueue and reload todos when connection is restored',
      build: () {
        when(() => mockSyncManager.processSyncQueue()).thenAnswer((_) async => {});
        when(() => mockGetTodosUseCase()).thenAnswer((_) async => [tTodo]);
        when(() => mockTodosRepository.getPendingSyncCount()).thenAnswer((_) async => 0);
        return todosBloc;
      },
      act: (bloc) => bloc.add(const ConnectivityChangedEvent(isConnected: true)),
      expect: () => [
        TodosLoaded(todos: [tTodo], isOffline: false, pendingSyncCount: 0),
      ],
      verify: (_) {
        verify(() => mockSyncManager.processSyncQueue()).called(1);
      },
    );
  });
}
