import '../entities/user.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserProfile> getUserProfile();

  Future<bool> verifySession();

  Future<void> logout();
}
