import '../entities/geofence_location.dart';

abstract class LocationsRepository {
  Future<List<GeofenceLocation>> getLocations();

  Future<void> saveLocation(GeofenceLocation location);

  Future<void> deleteLocation(String id);
}
