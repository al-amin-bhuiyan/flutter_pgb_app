import '../entities/geofence_location.dart';
import '../repositories/locations_repository.dart';

class GetLocationsUseCase {
  final LocationsRepository _repository;

  GetLocationsUseCase({
    required LocationsRepository repository,
  }) : _repository = repository;

  Future<List<GeofenceLocation>> call() {
    return _repository.getLocations();
  }
}
