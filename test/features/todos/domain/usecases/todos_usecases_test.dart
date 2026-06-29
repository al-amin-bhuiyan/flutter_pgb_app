import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/todos/domain/entities/todo.dart';
import 'package:flutter_pgb_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:flutter_pgb_app/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:flutter_pgb_app/features/todos/domain/usecases/save_todo_usecase.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  late MockTodosRepository mockRepository;
  late GetTodosUseCase getTodosUseCase;
  late SaveTodoUseCase saveTodoUseCase;

  setUp(() {
    mockRepository = MockTodosRepository();
    getTodosUseCase = GetTodosUseCase(repository: mockRepository);
    saveTodoUseCase = SaveTodoUseCase(repository: mockRepository);
  });

  final tTodo = Todo(
    id: '1',
    title: 'Test Todo',
    isCompleted: false,
    updatedAt: DateTime(2026, 6, 29),
  );

  group('GetTodosUseCase', () {
    test('should return list of todos from repository', () async {
      when(() => mockRepository.getTodos()).thenAnswer((_) async => [tTodo]);

      final result = await getTodosUseCase();

      expect(result, [tTodo]);
      verify(() => mockRepository.getTodos()).called(1);
    });
  });

  group('SaveTodoUseCase', () {
    test('should save todo in repository', () async {
      when(() => mockRepository.saveTodo(tTodo)).thenAnswer((_) async {});

      await saveTodoUseCase(tTodo);

      verify(() => mockRepository.saveTodo(tTodo)).called(1);
    });
  });
}
