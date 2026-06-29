import '../../../../core/database/hive_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../models/user_profile_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveService _hiveService;
  final SecureStorageHelper _storageHelper;

  static const String _profileKey = 'user_profile';

  AuthLocalDataSourceImpl({
    required HiveService hiveService,
    required SecureStorageHelper storageHelper,
  })  : _hiveService = hiveService,
        _storageHelper = storageHelper;

  @override
  Future<void> cacheUserProfile(UserProfileModel userProfile) async {
    try {
      final box = _hiveService.getBox<UserProfileModel>('user_box');
      await box.put(_profileKey, userProfile);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final box = _hiveService.getBox<UserProfileModel>('user_box');
      return box.get(_profileKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storageHelper.writeAccessToken(accessToken);
      await _storageHelper.writeRefreshToken(refreshToken);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storageHelper.readAccessToken();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storageHelper.readRefreshToken();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _storageHelper.clearAll();
      final box = _hiveService.getBox<UserProfileModel>('user_box');
      await box.delete(_profileKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
