import 'package:hive_ce/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 0)
class UserProfileModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
    );
  }
}
