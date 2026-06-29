import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_pgb_app/core/database/hive_service.dart';
import 'package:flutter_pgb_app/features/locations/data/datasources/locations_local_data_source.dart';
import 'package:flutter_pgb_app/features/locations/data/datasources/locations_local_data_source_impl.dart';
import 'package:flutter_pgb_app/features/locations/data/models/geofence_location_model.dart';
import 'package:flutter_pgb_app/core/error/exceptions.dart';

class MockHiveService extends Mock implements HiveService {}
class MockHiveBox extends Mock implements Box<GeofenceLocationModel> {}

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

  late MockHiveService mockHiveService;
  late MockHiveBox mockHiveBox;
  late LocationsLocalDataSource dataSource;

  setUp(() {
    mockHiveService = MockHiveService();
    mockHiveBox = MockHiveBox();
    dataSource = LocationsLocalDataSourceImpl(hiveService: mockHiveService);
  });

  const tLocationModel = GeofenceLocationModel(
    id: '1',
    name: 'Office',
    latitude: 23.8103,
    longitude: 90.4125,
    radius: 100.0,
  );

  group('getCachedLocations', () {
    test('should return list of cached locations from Hive box', () async {
      when(() => mockHiveService.getBox<GeofenceLocationModel>('locations_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.values).thenReturn([tLocationModel]);

      final result = await dataSource.getCachedLocations();

      expect(result, [tLocationModel]);
      verify(() => mockHiveService.getBox<GeofenceLocationModel>('locations_box')).called(1);
    });

    test('should throw CacheException when Hive fails', () async {
      when(() => mockHiveService.getBox<GeofenceLocationModel>('locations_box')).thenThrow(
        Exception('Hive error'),
      );

      final call = dataSource.getCachedLocations();

      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('cacheLocations', () {
    test('should clear and store all locations in Hive box', () async {
      when(() => mockHiveService.getBox<GeofenceLocationModel>('locations_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.clear()).thenAnswer((_) async => 0);
      when(() => mockHiveBox.putAll(any())).thenAnswer((_) async => {});

      await dataSource.cacheLocations([tLocationModel]);

      verify(() => mockHiveBox.clear()).called(1);
      verify(() => mockHiveBox.putAll({'1': tLocationModel})).called(1);
    });
  });

  group('cacheLocation', () {
    test('should store a location in Hive box with key as id', () async {
      when(() => mockHiveService.getBox<GeofenceLocationModel>('locations_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.put(any(), any())).thenAnswer((_) async => {});

      await dataSource.cacheLocation(tLocationModel);

      verify(() => mockHiveBox.put('1', tLocationModel)).called(1);
    });
  });

  group('deleteLocation', () {
    test('should remove a location from Hive box by id', () async {
      when(() => mockHiveService.getBox<GeofenceLocationModel>('locations_box')).thenReturn(mockHiveBox);
      when(() => mockHiveBox.delete(any())).thenAnswer((_) async => {});

      await dataSource.deleteLocation('1');

      verify(() => mockHiveBox.delete('1')).called(1);
    });
  });
}
