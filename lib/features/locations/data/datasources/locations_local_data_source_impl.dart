import '../../../../core/database/hive_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/geofence_location_model.dart';
import 'locations_local_data_source.dart';

class LocationsLocalDataSourceImpl implements LocationsLocalDataSource {
  final HiveService _hiveService;

  LocationsLocalDataSourceImpl({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  @override
  Future<List<GeofenceLocationModel>> getCachedLocations() async {
    try {
      final box = _hiveService.getBox<GeofenceLocationModel>('locations_box');
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheLocations(List<GeofenceLocationModel> locations) async {
    try {
      final box = _hiveService.getBox<GeofenceLocationModel>('locations_box');
      await box.clear();
      final map = {for (var loc in locations) loc.id: loc};
      await box.putAll(map);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheLocation(GeofenceLocationModel location) async {
    try {
      final box = _hiveService.getBox<GeofenceLocationModel>('locations_box');
      await box.put(location.id, location);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      final box = _hiveService.getBox<GeofenceLocationModel>('locations_box');
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
