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
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
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
