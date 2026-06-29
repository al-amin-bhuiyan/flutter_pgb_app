import '../../../todos/domain/entities/todo.dart';
import '../../../todos/domain/repositories/todos_repository.dart';

class SyncTodosUseCase {
  final TodosRepository _repository;

  SyncTodosUseCase({
    required TodosRepository repository,
  }) : _repository = repository;

  Future<void> call(List<Todo> todos) {
    return _repository.syncTodos(todos);
  }
}
