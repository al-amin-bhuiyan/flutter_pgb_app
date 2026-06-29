import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

class SaveTodoUseCase {
  final TodosRepository _repository;

  SaveTodoUseCase({
    required TodosRepository repository,
  }) : _repository = repository;

  Future<void> call(Todo todo) {
    return _repository.saveTodo(todo);
  }
}
