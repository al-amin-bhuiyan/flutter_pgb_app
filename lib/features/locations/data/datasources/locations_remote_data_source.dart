import '../models/geofence_location_model.dart';

abstract class LocationsRemoteDataSource {
  Future<List<GeofenceLocationModel>> getLocations();
  Future<void> saveLocation(GeofenceLocationModel location);
  Future<void> deleteLocation(String id);
}
