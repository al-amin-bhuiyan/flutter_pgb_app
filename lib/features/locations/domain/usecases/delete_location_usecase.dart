import '../repositories/locations_repository.dart';

class DeleteLocationUseCase {
  final LocationsRepository _repository;

  DeleteLocationUseCase({
    required LocationsRepository repository,
  }) : _repository = repository;

  Future<void> call(String id) {
    return _repository.deleteLocation(id);
  }
}
