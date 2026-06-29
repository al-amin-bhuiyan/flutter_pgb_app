import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../database/hive_service.dart';
import '../storage/secure_storage_helper.dart';
import '../network/dio_client.dart';
import '../network/token_refresh_service.dart';
import '../network/queued_auth_interceptor.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source_impl.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_session_usecase.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  final hiveService = HiveServiceImpl();
  await hiveService.init();
  sl.registerSingleton<HiveService>(hiveService);

  const storage = FlutterSecureStorage();
  sl.registerLazySingleton<SecureStorageHelper>(() => SecureStorageHelper(storage: storage));

  const baseUrl = 'https://todo.progressivebyte.com';

  // Network & Dio Setup
  final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
  sl.registerLazySingleton<TokenRefreshService>(
    () => TokenRefreshService(dio: refreshDio, storageHelper: sl<SecureStorageHelper>()),
  );

  sl.registerLazySingleton<DioClient>(() {
    final client = DioClient(
      baseUrl: baseUrl,
      interceptors: [],
    );
    client.dio.interceptors.add(
      QueuedAuthInterceptor(
        storageHelper: sl<SecureStorageHelper>(),
        refreshService: sl<TokenRefreshService>(),
        mainDio: client.dio,
      ),
    );
    return client;
  });

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      hiveService: sl<HiveService>(),
      storageHelper: sl<SecureStorageHelper>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifySessionUseCase(repository: sl<AuthRepository>()));
}
