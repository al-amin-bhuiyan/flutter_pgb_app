import '../models/geofence_location_model.dart';

abstract class LocationsLocalDataSource {
  Future<List<GeofenceLocationModel>> getCachedLocations();
  Future<void> cacheLocations(List<GeofenceLocationModel> locations);
  Future<void> cacheLocation(GeofenceLocationModel location);
  Future<void> deleteLocation(String id);
}
