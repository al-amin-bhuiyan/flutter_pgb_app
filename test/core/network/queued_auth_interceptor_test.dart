import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pgb_app/core/network/queued_auth_interceptor.dart';
import 'package:flutter_pgb_app/core/network/token_refresh_service.dart';
import 'package:flutter_pgb_app/core/storage/secure_storage_helper.dart';

class MockSecureStorageHelper extends Mock implements SecureStorageHelper {}
class MockTokenRefreshService extends Mock implements TokenRefreshService {}
class MockDio extends Mock implements Dio {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late MockSecureStorageHelper mockStorageHelper;
  late MockTokenRefreshService mockRefreshService;
  late MockDio mockDio;
  late QueuedAuthInterceptor interceptor;

  setUp(() {
    mockStorageHelper = MockSecureStorageHelper();
    mockRefreshService = MockTokenRefreshService();
    mockDio = MockDio();
    interceptor = QueuedAuthInterceptor(
      storageHelper: mockStorageHelper,
      refreshService: mockRefreshService,
      mainDio: mockDio,
    );
  });

  group('QueuedAuthInterceptor', () {
    test('onRequest adds authorization header when token exists', () async {
      const token = 'test_token';
      when(() => mockStorageHelper.readAccessToken()).thenAnswer((_) async => token);

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer $token');
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest does not add authorization header when token is null', () async {
      when(() => mockStorageHelper.readAccessToken()).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], isNull);
      verify(() => handler.next(options)).called(1);
    });
  });
}
