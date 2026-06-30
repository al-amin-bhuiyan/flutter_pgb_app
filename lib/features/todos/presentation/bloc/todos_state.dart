import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object?> get props => [];
}

class TodosInitial extends TodosState {}

class TodosLoading extends TodosState {}

class TodosLoaded extends TodosState {
  final List<Todo> todos;
  final bool isOffline;
  final int pendingSyncCount;

  const TodosLoaded({
    required this.todos,
    required this.isOffline,
    required this.pendingSyncCount,
  });

  @override
  List<Object?> get props => [todos, isOffline, pendingSyncCount];
}

class TodosError extends TodosState {
  final String message;

  const TodosError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class TodoActionSuccess extends TodosState {
  final String message;

  const TodoActionSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
