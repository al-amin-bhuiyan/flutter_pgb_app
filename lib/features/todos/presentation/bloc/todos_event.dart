import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodosEvent {}

class AddTodoEvent extends TodosEvent {
  final String title;

  const AddTodoEvent({
    required this.title,
  });

  @override
  List<Object?> get props => [title];
}

class ToggleTodoStatusEvent extends TodosEvent {
  final Todo todo;

  const ToggleTodoStatusEvent({
    required this.todo,
  });

  @override
  List<Object?> get props => [todo];
}

class ConnectivityChangedEvent extends TodosEvent {
  final bool isConnected;

  const ConnectivityChangedEvent({
    required this.isConnected,
  });

  @override
  List<Object?> get props => [isConnected];
}
