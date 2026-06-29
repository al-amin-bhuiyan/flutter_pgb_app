import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _localDataSource.cacheTokens(
      accessToken: userModel.token,
      refreshToken: userModel.refreshToken ?? '',
    );

    try {
      final profile = await _remoteDataSource.getUserProfile();
      await _localDataSource.cacheUserProfile(profile);
    } catch (_) {
      // Proceed even if profile caching fails, as tokens are cached.
    }

    return userModel;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );

    await _localDataSource.cacheTokens(
      accessToken: userModel.token,
      refreshToken: userModel.refreshToken ?? '',
    );

    try {
      final profile = await _remoteDataSource.getUserProfile();
      await _localDataSource.cacheUserProfile(profile);
    } catch (_) {
      await _localDataSource.cacheUserProfile(
        UserProfileModel(
          id: userModel.id,
          name: name,
          email: email,
        ),
      );
    }

    return userModel;
  }

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final remoteProfile = await _remoteDataSource.getUserProfile();
      await _localDataSource.cacheUserProfile(remoteProfile);
      return remoteProfile.toEntity();
    } catch (e) {
      final localProfile = await _localDataSource.getUserProfile();
      if (localProfile != null) {
        return localProfile.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<bool> verifySession() async {
    final token = await _localDataSource.getAccessToken();
    final refreshToken = await _localDataSource.getRefreshToken();
    return token != null && token.isNotEmpty && refreshToken != null && refreshToken.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearSession();
  }
}
