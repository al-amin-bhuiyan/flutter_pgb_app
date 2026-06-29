import 'package:equatable/equatable.dart';

class GeofenceLocation extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;

  const GeofenceLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude, radius];
}
