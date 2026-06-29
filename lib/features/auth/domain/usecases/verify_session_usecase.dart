import '../repositories/auth_repository.dart';

class VerifySessionUseCase {
  final AuthRepository _repository;

  VerifySessionUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<bool> call() {
    return _repository.verifySession();
  }
}
