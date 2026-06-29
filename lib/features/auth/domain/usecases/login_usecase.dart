import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase({
    required AuthRepository repository,
  }) : _repository = repository;

  Future<User> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
