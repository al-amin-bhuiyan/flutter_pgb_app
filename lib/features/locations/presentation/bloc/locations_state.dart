import 'package:equatable/equatable.dart';
import '../../domain/entities/geofence_location.dart';

abstract class LocationsState extends Equatable {
  const LocationsState();

  @override
  List<Object?> get props => [];
}

class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<GeofenceLocation> locations;

  const LocationsLoaded({
    required this.locations,
  });

  @override
  List<Object?> get props => [locations];
}

class LocationsActionSuccess extends LocationsState {
  final String message;

  const LocationsActionSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class LocationsError extends LocationsState {
  final String message;

  const LocationsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
