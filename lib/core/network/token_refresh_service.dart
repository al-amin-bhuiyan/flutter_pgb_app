import 'package:dio/dio.dart';
import '../storage/secure_storage_helper.dart';

class TokenRefreshService {
  final Dio _dio;
  final SecureStorageHelper _storageHelper;

  TokenRefreshService({
    required Dio dio,
    required SecureStorageHelper storageHelper,
  })  : _dio = dio,
        _storageHelper = storageHelper;

  Future<String?> refreshToken() async {
    final refreshToken = await _storageHelper.readRefreshToken();
    if (refreshToken == null) {
      return null;
    }

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;

        await _storageHelper.writeAccessToken(newAccessToken);
        await _storageHelper.writeRefreshToken(newRefreshToken);

        return newAccessToken;
      }
    } catch (_) {
      await _storageHelper.clearAll();
    }
    return null;
  }
}
