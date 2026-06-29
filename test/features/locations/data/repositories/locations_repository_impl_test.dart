import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_pgb_app/features/locations/data/datasources/locations_local_data_source.dart';
import 'package:flutter_pgb_app/features/locations/data/datasources/locations_remote_data_source.dart';
import 'package:flutter_pgb_app/features/locations/data/models/geofence_location_model.dart';
import 'package:flutter_pgb_app/features/locations/data/repositories/locations_repository_impl.dart';
import 'package:flutter_pgb_app/features/locations/domain/entities/geofence_location.dart';
import 'package:flutter_pgb_app/features/locations/domain/repositories/locations_repository.dart';

class MockLocationsRemoteDataSource extends Mock implements LocationsRemoteDataSource {}
class MockLocationsLocalDataSource extends Mock implements LocationsLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const GeofenceLocationModel(
        id: 'dummy',
        name: 'dummy',
        latitude: 0,
        longitude: 0,
        radius: 0,
      ),
    );
  });

  late MockLocationsRemoteDataSource mockRemoteDataSource;
  late MockLocationsLocalDataSource mockLocalDataSource;
  late LocationsRepository repository;

  setUp(() {
    mockRemoteDataSource = MockLocationsRemoteDataSource();
    mockLocalDataSource = MockLocationsLocalDataSource();
    repository = LocationsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tLocation = GeofenceLocation(
    id: '1',
    name: 'Office',
    latitude: 23.8103,
    longitude: 90.4125,
    radius: 100.0,
  );
  const tLocationModel = GeofenceLocationModel(
    id: '1',
    name: 'Office',
    latitude: 23.8103,
    longitude: 90.4125,
    radius: 100.0,
  );

  group('getLocations', () {
    test('should return remote locations and cache them when remote is successful', () async {
      when(() => mockRemoteDataSource.getLocations()).thenAnswer((_) async => [tLocationModel]);
      when(() => mockLocalDataSource.cacheLocations(any())).thenAnswer((_) async => {});

      final result = await repository.getLocations();

      expect(result, [tLocation]);
      verify(() => mockRemoteDataSource.getLocations()).called(1);
      verify(() => mockLocalDataSource.cacheLocations([tLocationModel])).called(1);
    });

    test('should fallback to local cache when remote fails', () async {
      when(() => mockRemoteDataSource.getLocations()).thenThrow(Exception('Server error'));
      when(() => mockLocalDataSource.getCachedLocations()).thenAnswer(
        (_) async => [tLocationModel],
      );

      final result = await repository.getLocations();

      expect(result, [tLocation]);
      verify(() => mockRemoteDataSource.getLocations()).called(1);
      verify(() => mockLocalDataSource.getCachedLocations()).called(1);
    });
  });

  group('saveLocation', () {
    test('should save location in remote and cache locally', () async {
      when(() => mockRemoteDataSource.saveLocation(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.cacheLocation(any())).thenAnswer((_) async => {});

      await repository.saveLocation(tLocation);

      verify(() => mockRemoteDataSource.saveLocation(any())).called(1);
      verify(() => mockLocalDataSource.cacheLocation(any())).called(1);
    });
  });

  group('deleteLocation', () {
    test('should delete location from remote and local cache', () async {
      when(() => mockRemoteDataSource.deleteLocation(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.deleteLocation(any())).thenAnswer((_) async => {});

      await repository.deleteLocation('1');

      verify(() => mockRemoteDataSource.deleteLocation('1')).called(1);
      verify(() => mockLocalDataSource.deleteLocation('1')).called(1);
    });
  });
}
