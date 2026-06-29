import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/locations/domain/entities/geofence_location.dart';
import 'package:flutter_pgb_app/features/locations/domain/repositories/locations_repository.dart';
import 'package:flutter_pgb_app/features/locations/domain/usecases/get_locations_usecase.dart';
import 'package:flutter_pgb_app/features/locations/domain/usecases/save_location_usecase.dart';
import 'package:flutter_pgb_app/features/locations/domain/usecases/delete_location_usecase.dart';

class MockLocationsRepository extends Mock implements LocationsRepository {}

void main() {
  late MockLocationsRepository mockRepository;
  late GetLocationsUseCase getLocationsUseCase;
  late SaveLocationUseCase saveLocationUseCase;
  late DeleteLocationUseCase deleteLocationUseCase;

  setUp(() {
    mockRepository = MockLocationsRepository();
    getLocationsUseCase = GetLocationsUseCase(repository: mockRepository);
    saveLocationUseCase = SaveLocationUseCase(repository: mockRepository);
    deleteLocationUseCase = DeleteLocationUseCase(repository: mockRepository);
  });

  const tLocation = GeofenceLocation(
    id: '1',
    name: 'Office',
    latitude: 23.8103,
    longitude: 90.4125,
    radius: 100.0,
  );

  group('GetLocationsUseCase', () {
    test('should return list of locations from repository', () async {
      when(() => mockRepository.getLocations()).thenAnswer((_) async => [tLocation]);

      final result = await getLocationsUseCase();

      expect(result, [tLocation]);
      verify(() => mockRepository.getLocations()).called(1);
    });
  });

  group('SaveLocationUseCase', () {
    test('should save location in repository', () async {
      when(() => mockRepository.saveLocation(tLocation)).thenAnswer((_) async {});

      await saveLocationUseCase(tLocation);

      verify(() => mockRepository.saveLocation(tLocation)).called(1);
    });
  });

  group('DeleteLocationUseCase', () {
    test('should delete location from repository', () async {
      when(() => mockRepository.deleteLocation('1')).thenAnswer((_) async {});

      await deleteLocationUseCase('1');

      verify(() => mockRepository.deleteLocation('1')).called(1);
    });
  });
}
