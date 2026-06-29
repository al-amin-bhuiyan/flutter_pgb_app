import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_pgb_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_pgb_app/features/auth/data/models/user_model.dart';
import 'package:flutter_pgb_app/features/auth/data/models/user_profile_model.dart';
import 'package:flutter_pgb_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_pgb_app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UserProfileModel(id: 'dummy', name: 'dummy', email: 'dummy'),
    );
  });

  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepository repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password';
  const tUserModel = UserModel(
    id: '1',
    email: tEmail,
    token: 'access_token',
    refreshToken: 'refresh_token',
  );
  const tUserProfileModel = UserProfileModel(
    id: '1',
    name: 'Test User',
    email: tEmail,
  );
  final tUserProfile = tUserProfileModel.toEntity();

  group('login', () {
    test('should return User and cache tokens and profile when remote login is successful', () async {
      when(() => mockRemoteDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.getUserProfile()).thenAnswer((_) async => tUserProfileModel);
      when(() => mockLocalDataSource.cacheUserProfile(any())).thenAnswer((_) async => {});

      final result = await repository.login(email: tEmail, password: tPassword);

      expect(result, tUserModel);
      verify(() => mockRemoteDataSource.login(email: tEmail, password: tPassword)).called(1);
      verify(() => mockLocalDataSource.cacheTokens(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          )).called(1);
      verify(() => mockRemoteDataSource.getUserProfile()).called(1);
      verify(() => mockLocalDataSource.cacheUserProfile(tUserProfileModel)).called(1);
    });
  });

  group('register', () {
    test('should return User and cache tokens and profile when remote registration is successful', () async {
      when(() => mockRemoteDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.getUserProfile()).thenAnswer((_) async => tUserProfileModel);
      when(() => mockLocalDataSource.cacheUserProfile(any())).thenAnswer((_) async => {});

      final result = await repository.register(
        name: 'Test User',
        email: tEmail,
        password: tPassword,
      );

      expect(result, tUserModel);
      verify(() => mockRemoteDataSource.register(
            name: 'Test User',
            email: tEmail,
            password: tPassword,
          )).called(1);
      verify(() => mockLocalDataSource.cacheTokens(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          )).called(1);
      verify(() => mockRemoteDataSource.getUserProfile()).called(1);
      verify(() => mockLocalDataSource.cacheUserProfile(tUserProfileModel)).called(1);
    });
  });

  group('getUserProfile', () {
    test('should return remote profile and cache it locally when remote is successful', () async {
      when(() => mockRemoteDataSource.getUserProfile()).thenAnswer((_) async => tUserProfileModel);
      when(() => mockLocalDataSource.cacheUserProfile(any())).thenAnswer((_) async => {});

      final result = await repository.getUserProfile();

      expect(result, tUserProfile);
      verify(() => mockRemoteDataSource.getUserProfile()).called(1);
      verify(() => mockLocalDataSource.cacheUserProfile(tUserProfileModel)).called(1);
    });

    test('should fallback to local cache when remote call fails', () async {
      when(() => mockRemoteDataSource.getUserProfile()).thenThrow(Exception('Server error'));
      when(() => mockLocalDataSource.getUserProfile()).thenAnswer((_) async => tUserProfileModel);

      final result = await repository.getUserProfile();

      expect(result, tUserProfile);
      verify(() => mockRemoteDataSource.getUserProfile()).called(1);
      verify(() => mockLocalDataSource.getUserProfile()).called(1);
    });
  });

  group('verifySession', () {
    test('should return true when access and refresh tokens are cached', () async {
      when(() => mockLocalDataSource.getAccessToken()).thenAnswer((_) async => 'access');
      when(() => mockLocalDataSource.getRefreshToken()).thenAnswer((_) async => 'refresh');

      final result = await repository.verifySession();

      expect(result, true);
    });

    test('should return false when access token is not cached', () async {
      when(() => mockLocalDataSource.getAccessToken()).thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken()).thenAnswer((_) async => 'refresh');

      final result = await repository.verifySession();

      expect(result, false);
    });
  });

  group('logout', () {
    test('should call clearSession on local data source', () async {
      when(() => mockLocalDataSource.clearSession()).thenAnswer((_) async => {});

      await repository.logout();

      verify(() => mockLocalDataSource.clearSession()).called(1);
    });
  });
}
