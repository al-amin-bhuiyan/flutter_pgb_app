import '../models/user_profile_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserProfile(UserProfileModel userProfile);
  Future<UserProfileModel?> getUserProfile();
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearSession();
}
