import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../locations/data/datasources/locations_local_data_source.dart';
import '../../domain/helpers/proximity_calculator.dart';
import 'notification_helper.dart';

class GeofenceManager {
  final LocationsLocalDataSource _localDataSource;
  final ProximityCalculator _proximityCalculator;
  final NotificationHelper _notificationHelper;

  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _insideLocations = {};

  GeofenceManager({
    required LocationsLocalDataSource localDataSource,
    required ProximityCalculator proximityCalculator,
    required NotificationHelper notificationHelper,
  })  : _localDataSource = localDataSource,
        _proximityCalculator = proximityCalculator,
        _notificationHelper = notificationHelper;

  void startMonitoring() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      _checkGeofences(position);
    });
  }

  Future<void> _checkGeofences(Position position) async {
    try {
      final locations = await _localDataSource.getCachedLocations();
      for (var loc in locations) {
        final distance = _proximityCalculator.calculateDistance(
          position.latitude,
          position.longitude,
          loc.latitude,
          loc.longitude,
        );

        final isInside = distance <= loc.radius;
        final alreadyInside = _insideLocations.contains(loc.id);

        if (isInside && !alreadyInside) {
          _insideLocations.add(loc.id);
          await _notificationHelper.showGeofenceAlert(loc.name);
        } else if (!isInside && alreadyInside) {
          _insideLocations.remove(loc.id);
        }
      }
    } catch (_) {}
  }

  void stopMonitoring() {
    _positionSubscription?.cancel();
  }
}
