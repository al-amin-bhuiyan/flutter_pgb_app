import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl({
    required DioClient client,
  }) : _client = client;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return _client.post(
      path: '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      fromJson: UserModel.fromJson,
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _client.post(
      path: '/auth/register',
      data: {
        'full_name': name,
        'email': email,
        'password': password,
      },
      fromJson: UserModel.fromJson,
    );
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    return _client.get(
      path: '/me',
      fromJson: (data) {
        final userMap = data['user'] != null
            ? data['user'] as Map<String, dynamic>
            : data;
        return UserProfileModel(
          id: userMap['id'] as String,
          name: userMap['name'] as String,
          email: userMap['email'] as String,
        );
      },
    );
  }
}
