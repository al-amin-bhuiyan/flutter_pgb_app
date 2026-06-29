import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pgb_app/core/network/dio_client.dart';
import 'package:flutter_pgb_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_pgb_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:flutter_pgb_app/features/auth/data/models/user_model.dart';
import 'package:flutter_pgb_app/features/auth/data/models/user_profile_model.dart';
import 'package:flutter_pgb_app/core/error/exceptions.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = AuthRemoteDataSourceImpl(client: mockDioClient);
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    const tUserModel = UserModel(
      id: '1',
      email: tEmail,
      token: 'token',
      refreshToken: 'refresh',
    );
    final tResponseData = {
      'id': '1',
      'email': tEmail,
      'token': 'token',
      'refreshToken': 'refresh',
    };

    test('should return UserModel when the response code is 200', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            data: tResponseData,
            statusCode: 200,
          ));

      final result = await dataSource.login(email: tEmail, password: tPassword);

      expect(result, tUserModel);
    });

    test('should throw ServerException when the response code is not 200', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 404,
            statusMessage: 'Not Found',
          ));

      final call = dataSource.login(email: tEmail, password: tPassword);

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('register', () {
    const tName = 'Test';
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    const tUserModel = UserModel(
      id: '1',
      email: tEmail,
      token: 'token',
      refreshToken: 'refresh',
    );
    final tResponseData = {
      'id': '1',
      'email': tEmail,
      'token': 'token',
      'refreshToken': 'refresh',
    };

    test('should return UserModel when the response code is 201', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/auth/register'),
            data: tResponseData,
            statusCode: 201,
          ));

      final result = await dataSource.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      expect(result, tUserModel);
    });
  });

  group('getUserProfile', () {
    final tProfileData = {
      'id': '1',
      'name': 'Test User',
      'email': 'test@example.com',
    };
    final tUserProfileModel = UserProfileModel(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
    );

    test('should return UserProfileModel when the response code is 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/auth/profile'),
            data: tProfileData,
            statusCode: 200,
          ));

      final result = await dataSource.getUserProfile();

      expect(result.id, tUserProfileModel.id);
      expect(result.name, tUserProfileModel.name);
      expect(result.email, tUserProfileModel.email);
    });
  });
}
