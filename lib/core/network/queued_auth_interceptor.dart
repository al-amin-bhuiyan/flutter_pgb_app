import 'package:dio/dio.dart';
import '../storage/secure_storage_helper.dart';
import 'token_refresh_service.dart';

class QueuedAuthInterceptor extends QueuedInterceptor {
  final SecureStorageHelper _storageHelper;
  final TokenRefreshService _refreshService;
  final Dio _mainDio;

  QueuedAuthInterceptor({
    required SecureStorageHelper storageHelper,
    required TokenRefreshService refreshService,
    required Dio mainDio,
  })  : _storageHelper = storageHelper,
        _refreshService = refreshService,
        _mainDio = mainDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageHelper.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final requestToken = err.requestOptions.headers['Authorization'] as String?;
      final currentToken = await _storageHelper.readAccessToken();

      if (currentToken != null && 'Bearer $currentToken' != requestToken) {
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $currentToken';
        try {
          final response = await _mainDio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }

      final newAccessToken = await _refreshService.refreshToken();
      if (newAccessToken != null) {
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final response = await _mainDio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }
    }
    handler.next(err);
  }
}
