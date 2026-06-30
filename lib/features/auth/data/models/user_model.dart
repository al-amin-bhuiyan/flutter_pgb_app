import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? refreshToken;

  const UserModel({
    required super.id,
    required super.email,
    required super.token,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>;
    return UserModel(
      id: userMap['id'] as String,
      email: userMap['email'] as String,
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
