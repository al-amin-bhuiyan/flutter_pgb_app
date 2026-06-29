import 'package:hive_ce_flutter/hive_ce_flutter.dart';

abstract class HiveService {
  Future<void> init();
  Box<T> getBox<T>(String name);
  Future<void> clear();
}

class HiveServiceImpl implements HiveService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('user_box');
    await Hive.openBox('locations_box');
    await Hive.openBox('todos_box');
    await Hive.openBox('sync_queue_box');
  }

  @override
  Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  @override
  Future<void> clear() async {
    await Hive.box('user_box').clear();
    await Hive.box('locations_box').clear();
    await Hive.box('todos_box').clear();
    await Hive.box('sync_queue_box').clear();
  }
}
