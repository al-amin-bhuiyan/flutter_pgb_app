import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/todos/domain/entities/todo.dart';
import 'package:flutter_pgb_app/features/todos/domain/repositories/todos_repository.dart';
import 'package:flutter_pgb_app/features/sync/domain/usecases/sync_todos_usecase.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  late MockTodosRepository mockRepository;
  late SyncTodosUseCase syncTodosUseCase;

  setUp(() {
    mockRepository = MockTodosRepository();
    syncTodosUseCase = SyncTodosUseCase(repository: mockRepository);
  });

  final tTodosList = [
    Todo(
      id: '1',
      title: 'Sync Target',
      isCompleted: true,
      updatedAt: DateTime(2026, 6, 29),
    )
  ];

  group('SyncTodosUseCase', () {
    test('should invoke syncTodos in repositories', () async {
      when(() => mockRepository.syncTodos(tTodosList)).thenAnswer((_) async {});

      await syncTodosUseCase(tTodosList);

      verify(() => mockRepository.syncTodos(tTodosList)).called(1);
    });
  });
}
