import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_pgb_app/core/database/hive_service.dart';
import 'package:flutter_pgb_app/core/storage/secure_storage_helper.dart';
import 'package:flutter_pgb_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_pgb_app/features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'package:flutter_pgb_app/features/auth/data/models/user_profile_model.dart';
import 'package:flutter_pgb_app/core/error/exceptions.dart';

class MockHiveService extends Mock implements HiveService {}
class MockSecureStorageHelper extends Mock implements SecureStorageHelper {}
class MockHiveBox extends Mock implements Box<UserProfileModel> {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UserProfileModel(id: 'dummy', name: 'dummy', email: 'dummy'),
    );
  });

  late MockHiveService mockHiveService;
  late MockSecureStorageHelper mockStorageHelper;
  late MockHiveBox mockHiveBox;
  late AuthLocalDataSource dataSource;

  setUp(() {
    mockHiveService = MockHiveService();
    mockStorageHelper = MockSecureStorageHelper();
    mockHiveBox = MockHiveBox();
    dataSource = AuthLocalDataSourceImpl(
      hiveService: mockHiveService,
      storageHelper: mockStorageHelper,
    );
  });

  group('cacheUserProfile', () {
    final tUserProfile = UserProfileModel(
      id: '1',
      name: 'Test',
      email: 'test@example.com',
    );

    test('should call Hive box.put with correct key and value', () async {
      when(() => mockHiveService.getBox<UserProfileModel>('user_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.put(any(), any())).thenAnswer((_) async => {});

      await dataSource.cacheUserProfile(tUserProfile);

      verify(() => mockHiveService.getBox<UserProfileModel>('user_box')).called(1);
      verify(() => mockHiveBox.put('user_profile', tUserProfile)).called(1);
    });

    test('should throw CacheException when Hive throws error', () async {
      when(() => mockHiveService.getBox<UserProfileModel>('user_box')).thenThrow(Exception('Hive error'));

      final call = dataSource.cacheUserProfile(tUserProfile);

      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('getUserProfile', () {
    final tUserProfile = UserProfileModel(
      id: '1',
      name: 'Test',
      email: 'test@example.com',
    );

    test('should return UserProfileModel from Hive box when present', () async {
      when(() => mockHiveService.getBox<UserProfileModel>('user_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.get('user_profile')).thenReturn(tUserProfile);

      final result = await dataSource.getUserProfile();

      expect(result, tUserProfile);
      verify(() => mockHiveBox.get('user_profile')).called(1);
    });
  });

  group('cacheTokens', () {
    test('should save tokens in SecureStorageHelper', () async {
      when(() => mockStorageHelper.writeAccessToken(any())).thenAnswer((_) async {});
      when(() => mockStorageHelper.writeRefreshToken(any())).thenAnswer((_) async {});

      await dataSource.cacheTokens(accessToken: 'access', refreshToken: 'refresh');

      verify(() => mockStorageHelper.writeAccessToken('access')).called(1);
      verify(() => mockStorageHelper.writeRefreshToken('refresh')).called(1);
    });
  });

  group('clearSession', () {
    test('should clear Hive box profile and clear SecureStorageHelper', () async {
      when(() => mockHiveService.getBox<UserProfileModel>('user_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.delete(any())).thenAnswer((_) async => {});
      when(() => mockStorageHelper.clearAll()).thenAnswer((_) async {});

      await dataSource.clearSession();

      verify(() => mockStorageHelper.clearAll()).called(1);
      verify(() => mockHiveBox.delete('user_profile')).called(1);
    });
  });
}
