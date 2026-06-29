import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pgb_app/features/geofence/domain/helpers/proximity_calculator.dart';

void main() {
  late ProximityCalculator calculator;

  setUp(() {
    calculator = ProximityCalculator();
  });

  group('ProximityCalculator Haversine distance tests', () {
    test('should return 0.0 when same start and end coordinates are provided', () {
      final distance = calculator.calculateDistance(23.8103, 90.4125, 23.8103, 90.4125);
      expect(distance, 0.0);
    });

    test('should calculate distance correctly between two close coordinates', () {
      // Coordinates representing approximately 135.6 meters distance in Dhaka
      final distance = calculator.calculateDistance(
        23.8103,
        90.4125,
        23.8112,
        90.4134,
      );

      // Distance should be close to 135.6 meters
      expect(distance, closeTo(135.6, 0.5));
    });

    test('should calculate distance correctly for long distance trip', () {
      // Dhaka to Chittagong coordinates (approx 213.9 km)
      final distance = calculator.calculateDistance(
        23.8103,
        90.4125,
        22.3569,
        91.7832,
      );

      // Expected distance is ~213,952 meters
      expect(distance, closeTo(213952.0, 500.0));
    });
  });
}
