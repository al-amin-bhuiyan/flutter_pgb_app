import '../../domain/entities/geofence_location.dart';
import '../../domain/repositories/locations_repository.dart';
import '../datasources/locations_local_data_source.dart';
import '../datasources/locations_remote_data_source.dart';
import '../models/geofence_location_model.dart';

class LocationsRepositoryImpl implements LocationsRepository {
  final LocationsRemoteDataSource _remoteDataSource;
  final LocationsLocalDataSource _localDataSource;

  LocationsRepositoryImpl({
    required LocationsRemoteDataSource remoteDataSource,
    required LocationsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<GeofenceLocation>> getLocations() async {
    try {
      final remoteLocations = await _remoteDataSource.getLocations();
      await _localDataSource.cacheLocations(remoteLocations);
      return remoteLocations.map((model) => model.toEntity()).toList();
    } catch (_) {
      final localLocations = await _localDataSource.getCachedLocations();
      if (localLocations.isNotEmpty) {
        return localLocations.map((model) => model.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<void> saveLocation(GeofenceLocation location) async {
    final model = GeofenceLocationModel.fromEntity(location);
    await _remoteDataSource.saveLocation(model);
    await _localDataSource.cacheLocation(model);
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _remoteDataSource.deleteLocation(id);
    await _localDataSource.deleteLocation(id);
  }
}
