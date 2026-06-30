import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/geofence_location.dart';
import '../../domain/usecases/delete_location_usecase.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import '../../domain/usecases/save_location_usecase.dart';
import 'locations_event.dart';
import 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final GetLocationsUseCase _getLocationsUseCase;
  final SaveLocationUseCase _saveLocationUseCase;
  final DeleteLocationUseCase _deleteLocationUseCase;

  LocationsBloc({
    required GetLocationsUseCase getLocationsUseCase,
    required SaveLocationUseCase saveLocationUseCase,
    required DeleteLocationUseCase deleteLocationUseCase,
  })  : _getLocationsUseCase = getLocationsUseCase,
        _saveLocationUseCase = saveLocationUseCase,
        _deleteLocationUseCase = deleteLocationUseCase,
        super(LocationsInitial()) {
    on<LoadLocationsEvent>(_onLoadLocations);
    on<AddLocationEvent>(_onAddLocation);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<DeleteLocationEvent>(_onDeleteLocation);
  }

  Future<void> _onLoadLocations(
    LoadLocationsEvent event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    try {
      final locations = await _getLocationsUseCase();
      emit(LocationsLoaded(locations: locations));
    } catch (e) {
      emit(LocationsError(message: e.toString()));
    }
  }

  Future<void> _onAddLocation(
    AddLocationEvent event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final location = GeofenceLocation(
        id: id,
        name: event.name,
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
      );
      await _saveLocationUseCase(location);
      emit(const LocationsActionSuccess(message: 'Location added successfully'));
    } catch (e) {
      emit(LocationsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    try {
      await _saveLocationUseCase(event.location);
      emit(const LocationsActionSuccess(message: 'Location updated successfully'));
    } catch (e) {
      emit(LocationsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocationEvent event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    try {
      await _deleteLocationUseCase(event.id);
      emit(const LocationsActionSuccess(message: 'Location deleted successfully'));
    } catch (e) {
      emit(LocationsError(message: e.toString()));
    }
  }
}
