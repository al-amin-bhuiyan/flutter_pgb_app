import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pgb_app/features/auth/domain/entities/user.dart';
import 'package:flutter_pgb_app/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_pgb_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_pgb_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_pgb_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_pgb_app/features/auth/domain/usecases/verify_session_usecase.dart';
import 'package:flutter_pgb_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_pgb_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_pgb_app/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockVerifySessionUseCase extends Mock implements VerifySessionUseCase {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockVerifySessionUseCase mockVerifySessionUseCase;
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockVerifySessionUseCase = MockVerifySessionUseCase();
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      verifySessionUseCase: mockVerifySessionUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tUser = User(
    id: '1',
    email: 'john.doe@example.com',
    token: 'jwt-access-token',
  );

  const tProfile = UserProfile(
    id: '1',
    name: 'John Doe',
    email: 'john.doe@example.com',
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, AuthInitial());
  });

  group('AppStartedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when session is verified successfully',
      build: () {
        when(() => mockVerifySessionUseCase()).thenAnswer((_) async => true);
        when(() => mockAuthRepository.getUserProfile()).thenAnswer((_) async => tProfile);
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStartedEvent()),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: User(id: '1', email: 'john.doe@example.com', token: '')),
      ],
      verify: (_) {
        verify(() => mockVerifySessionUseCase()).called(1);
        verify(() => mockAuthRepository.getUserProfile()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when session is not verified',
      build: () {
        when(() => mockVerifySessionUseCase()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStartedEvent()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when verification throws an error',
      build: () {
        when(() => mockVerifySessionUseCase()).thenThrow(Exception('Verification failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStartedEvent()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });

  group('LoginSubmittedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when login is successful',
      build: () {
        when(() => mockLoginUseCase(
              email: 'john.doe@example.com',
              password: 'secretpassword',
            )).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmittedEvent(
        email: 'john.doe@example.com',
        password: 'secretpassword',
      )),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUseCase(
              email: 'john.doe@example.com',
              password: 'secretpassword',
            )).thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmittedEvent(
        email: 'john.doe@example.com',
        password: 'secretpassword',
      )),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Exception: Invalid credentials'),
      ],
    );
  });

  group('RegisterSubmittedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when registration is successful',
      build: () {
        when(() => mockRegisterUseCase(
              name: 'John Doe',
              email: 'john.doe@example.com',
              password: 'secretpassword',
            )).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterSubmittedEvent(
        name: 'John Doe',
        email: 'john.doe@example.com',
        password: 'secretpassword',
      )),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when registration fails',
      build: () {
        when(() => mockRegisterUseCase(
              name: 'John Doe',
              email: 'john.doe@example.com',
              password: 'secretpassword',
            )).thenThrow(Exception('Server registration failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterSubmittedEvent(
        name: 'John Doe',
        email: 'john.doe@example.com',
        password: 'secretpassword',
      )),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Exception: Server registration failed'),
      ],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when logout is successful',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockAuthRepository.logout()).thenThrow(Exception('Logout failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Exception: Logout failed'),
      ],
    );
  });
}
