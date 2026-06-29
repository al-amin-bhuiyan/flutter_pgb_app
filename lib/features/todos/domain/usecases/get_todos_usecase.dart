import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

class GetTodosUseCase {
  final TodosRepository _repository;

  GetTodosUseCase({
    required TodosRepository repository,
  }) : _repository = repository;

  Future<List<Todo>> call() {
    return _repository.getTodos();
  }
}
