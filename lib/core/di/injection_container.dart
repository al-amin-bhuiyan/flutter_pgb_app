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

import '../../features/locations/data/datasources/locations_local_data_source.dart';
import '../../features/locations/data/datasources/locations_local_data_source_impl.dart';
import '../../features/locations/data/datasources/locations_remote_data_source.dart';
import '../../features/locations/data/datasources/locations_remote_data_source_impl.dart';
import '../../features/locations/data/repositories/locations_repository_impl.dart';
import '../../features/locations/domain/repositories/locations_repository.dart';
import '../../features/locations/domain/usecases/get_locations_usecase.dart';
import '../../features/locations/domain/usecases/save_location_usecase.dart';
import '../../features/locations/domain/usecases/delete_location_usecase.dart';

import '../../features/todos/data/datasources/todos_local_data_source.dart';
import '../../features/todos/data/datasources/todos_local_data_source_impl.dart';
import '../../features/todos/data/datasources/todos_remote_data_source.dart';
import '../../features/todos/data/datasources/todos_remote_data_source_impl.dart';
import '../../features/todos/data/repositories/todos_repository_impl.dart';
import '../../features/todos/domain/repositories/todos_repository.dart';
import '../../features/todos/domain/usecases/get_todos_usecase.dart';
import '../../features/todos/domain/usecases/save_todo_usecase.dart';
import '../../features/sync/domain/usecases/sync_todos_usecase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/network_info.dart';
import '../network/network_info_impl.dart';
import '../../features/sync/data/services/sync_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/geofence/data/services/permission_manager.dart';
import '../../features/geofence/data/services/notification_helper.dart';
import '../../features/geofence/domain/helpers/proximity_calculator.dart';
import '../../features/geofence/data/services/geofence_manager.dart';




final sl = GetIt.instance;

Future<void> initDI() async {
  final hiveService = HiveServiceImpl();
  await hiveService.init();
  sl.registerSingleton<HiveService>(hiveService);

  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: sl<Connectivity>()));

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

  // Data Sources - Authentication
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      hiveService: sl<HiveService>(),
      storageHelper: sl<SecureStorageHelper>(),
    ),
  );

  // Repositories - Authentication
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use cases - Authentication
  sl.registerLazySingleton(() => LoginUseCase(repository: sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifySessionUseCase(repository: sl<AuthRepository>()));

  // Data Sources - Locations
  sl.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<LocationsLocalDataSource>(
    () => LocationsLocalDataSourceImpl(hiveService: sl<HiveService>()),
  );

  // Repositories - Locations
  sl.registerLazySingleton<LocationsRepository>(
    () => LocationsRepositoryImpl(
      remoteDataSource: sl<LocationsRemoteDataSource>(),
      localDataSource: sl<LocationsLocalDataSource>(),
    ),
  );

  // Use cases - Locations
  sl.registerLazySingleton(() => GetLocationsUseCase(repository: sl<LocationsRepository>()));
  sl.registerLazySingleton(() => SaveLocationUseCase(repository: sl<LocationsRepository>()));
  sl.registerLazySingleton(() => DeleteLocationUseCase(repository: sl<LocationsRepository>()));

  // Data Sources - Todos
  sl.registerLazySingleton<TodosRemoteDataSource>(
    () => TodosRemoteDataSourceImpl(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<TodosLocalDataSource>(
    () => TodosLocalDataSourceImpl(hiveService: sl<HiveService>()),
  );

  // Repositories - Todos
  sl.registerLazySingleton<TodosRepository>(
    () => TodosRepositoryImpl(
      remoteDataSource: sl<TodosRemoteDataSource>(),
      localDataSource: sl<TodosLocalDataSource>(),
    ),
  );

  // Use cases - Todos
  sl.registerLazySingleton(() => GetTodosUseCase(repository: sl<TodosRepository>()));
  sl.registerLazySingleton(() => SaveTodoUseCase(repository: sl<TodosRepository>()));
  sl.registerLazySingleton(() => SyncTodosUseCase(repository: sl<TodosRepository>()));

  // Sync Manager Service
  sl.registerSingleton<SyncManager>(
    SyncManager(
      networkInfo: sl<NetworkInfo>(),
      localDataSource: sl<TodosLocalDataSource>(),
      todosRepository: sl<TodosRepository>(),
    )..initialize(),
  );

  // Geofence & Notifications Services
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton<NotificationHelper>(
    () => NotificationHelper(notificationsPlugin: sl<FlutterLocalNotificationsPlugin>()),
  );
  sl.registerLazySingleton<ProximityCalculator>(() => ProximityCalculator());
  sl.registerLazySingleton<PermissionManager>(() => PermissionManagerImpl());

  sl.registerLazySingleton<GeofenceManager>(
    () => GeofenceManager(
      localDataSource: sl<LocationsLocalDataSource>(),
      proximityCalculator: sl<ProximityCalculator>(),
      notificationHelper: sl<NotificationHelper>(),
    ),
  );
}
