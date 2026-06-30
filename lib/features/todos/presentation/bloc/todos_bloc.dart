import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_info.dart';
import '../../../sync/data/services/sync_manager.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/save_todo_usecase.dart';
import 'todos_event.dart';
import 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final GetTodosUseCase _getTodosUseCase;
  final SaveTodoUseCase _saveTodoUseCase;
  final TodosRepository _todosRepository;
  final NetworkInfo _networkInfo;
  final SyncManager _syncManager;
  StreamSubscription<bool>? _connectivitySubscription;

  TodosBloc({
    required GetTodosUseCase getTodosUseCase,
    required SaveTodoUseCase saveTodoUseCase,
    required TodosRepository todosRepository,
    required NetworkInfo networkInfo,
    required SyncManager syncManager,
  })  : _getTodosUseCase = getTodosUseCase,
        _saveTodoUseCase = saveTodoUseCase,
        _todosRepository = todosRepository,
        _networkInfo = networkInfo,
        _syncManager = syncManager,
        super(TodosInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoStatusEvent>(_onToggleTodoStatus);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
    on<SyncTodosManuallyEvent>(_onSyncTodosManually);

    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isConnected) {
      add(ConnectivityChangedEvent(isConnected: isConnected));
    });
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodosLoading());
    try {
      final todos = await _getTodosUseCase();
      final isOffline = !await _networkInfo.isConnected;
      final pendingCount = await _todosRepository.getPendingSyncCount();
      
      // Sort todos by updatedAt descending so new/edited ones show first
      todos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(TodosLoaded(
        todos: todos,
        isOffline: isOffline,
        pendingSyncCount: pendingCount,
      ));
    } catch (e) {
      emit(TodosError(message: e.toString()));
    }
  }

  Future<void> _onAddTodo(
    AddTodoEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodosLoading());
    try {
      final todo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        isCompleted: false,
        updatedAt: DateTime.now(),
      );
      await _saveTodoUseCase(todo);
      emit(const TodoActionSuccess(message: 'Todo added successfully'));
    } catch (e) {
      emit(TodosError(message: e.toString()));
    }
  }

  Future<void> _onToggleTodoStatus(
    ToggleTodoStatusEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodosLoading());
    try {
      final updatedTodo = event.todo.copyWith(
        isCompleted: !event.todo.isCompleted,
        updatedAt: DateTime.now(),
      );
      await _saveTodoUseCase(updatedTodo);
      emit(const TodoActionSuccess(message: 'Task updated successfully'));
    } catch (e) {
      emit(TodosError(message: e.toString()));
    }
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChangedEvent event,
    Emitter<TodosState> emit,
  ) async {
    if (event.isConnected) {
      await _syncManager.processSyncQueue();
    }
    // Reload todos and status metrics
    final todos = await _getTodosUseCase();
    final isOffline = !event.isConnected;
    final pendingCount = await _todosRepository.getPendingSyncCount();
    todos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    emit(TodosLoaded(
      todos: todos,
      isOffline: isOffline,
      pendingSyncCount: pendingCount,
    ));
  }

  Future<void> _onSyncTodosManually(
    SyncTodosManuallyEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(TodosLoading());
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const SocketException('No internet connection available');
      }
      
      await _syncManager.processSyncQueue();
      
      final todos = await _getTodosUseCase();
      final pendingCount = await _todosRepository.getPendingSyncCount();
      todos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      emit(const TodoActionSuccess(message: 'Manual sync completed successfully'));
      emit(TodosLoaded(
        todos: todos,
        isOffline: false,
        pendingSyncCount: pendingCount,
      ));
    } catch (e) {
      final todos = await _getTodosUseCase();
      final isOffline = !await _networkInfo.isConnected;
      final pendingCount = await _todosRepository.getPendingSyncCount();
      todos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      emit(TodosError(message: e.toString()));
      emit(TodosLoaded(
        todos: todos,
        isOffline: isOffline,
        pendingSyncCount: pendingCount,
      ));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
