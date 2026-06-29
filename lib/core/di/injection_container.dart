import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/hive_service.dart';
import '../storage/secure_storage_helper.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  final hiveService = HiveServiceImpl();
  await hiveService.init();
  sl.registerSingleton<HiveService>(hiveService);

  const storage = FlutterSecureStorage();
  sl.registerLazySingleton<SecureStorageHelper>(() => SecureStorageHelper(storage: storage));
}
