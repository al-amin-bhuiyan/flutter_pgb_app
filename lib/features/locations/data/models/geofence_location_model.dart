import 'package:hive_ce/hive.dart';
import '../../domain/entities/geofence_location.dart';

part 'geofence_location_model.g.dart';

@HiveType(typeId: 1)
class GeofenceLocationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final double radius;

  const GeofenceLocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory GeofenceLocationModel.fromEntity(GeofenceLocation entity) {
    return GeofenceLocationModel(
      id: entity.id,
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      radius: entity.radius,
    );
  }

  factory GeofenceLocationModel.fromJson(Map<String, dynamic> json) {
    return GeofenceLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  GeofenceLocation toEntity() {
    return GeofenceLocation(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}
