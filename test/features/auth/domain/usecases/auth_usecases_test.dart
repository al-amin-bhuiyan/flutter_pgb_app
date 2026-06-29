import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/auth/domain/entities/user.dart';
import 'package:flutter_pgb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_pgb_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_pgb_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_pgb_app/features/auth/domain/usecases/verify_session_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late VerifySessionUseCase verifySessionUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository: mockRepository);
    registerUseCase = RegisterUseCase(repository: mockRepository);
    verifySessionUseCase = VerifySessionUseCase(repository: mockRepository);
  });

  const tUser = User(id: '1', email: 'test@example.com', token: 'token');

  group('LoginUseCase', () {
    test('should return User from the repository when successful', () async {
      when(() => mockRepository.login(
            email: 'test@example.com',
            password: 'password',
          )).thenAnswer((_) async => tUser);

      final result = await loginUseCase(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result, tUser);
      verify(() => mockRepository.login(
            email: 'test@example.com',
            password: 'password',
          )).called(1);
    });
  });

  group('RegisterUseCase', () {
    test('should return User from the repository when successful', () async {
      when(() => mockRepository.register(
            name: 'Test',
            email: 'test@example.com',
            password: 'password',
          )).thenAnswer((_) async => tUser);

      final result = await registerUseCase(
        name: 'Test',
        email: 'test@example.com',
        password: 'password',
      );

      expect(result, tUser);
      verify(() => mockRepository.register(
            name: 'Test',
            email: 'test@example.com',
            password: 'password',
          )).called(1);
    });
  });

  group('VerifySessionUseCase', () {
    test('should return true when session is valid', () async {
      when(() => mockRepository.verifySession()).thenAnswer((_) async => true);

      final result = await verifySessionUseCase();

      expect(result, true);
      verify(() => mockRepository.verifySession()).called(1);
    });
  });
}
