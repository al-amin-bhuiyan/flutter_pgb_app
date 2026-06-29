import '../entities/geofence_location.dart';
import '../repositories/locations_repository.dart';

class SaveLocationUseCase {
  final LocationsRepository _repository;

  SaveLocationUseCase({
    required LocationsRepository repository,
  }) : _repository = repository;

  Future<void> call(GeofenceLocation location) {
    return _repository.saveLocation(location);
  }
}
