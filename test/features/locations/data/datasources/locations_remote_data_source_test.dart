import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pgb_app/core/network/dio_client.dart';
import 'package:flutter_pgb_app/features/locations/data/datasources/locations_remote_data_source.dart';
import 'package:flutter_pgb_app/features/locations/data/datasources/locations_remote_data_source_impl.dart';
import 'package:flutter_pgb_app/features/locations/data/models/geofence_location_model.dart';
import 'package:flutter_pgb_app/core/error/exceptions.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late LocationsRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = LocationsRemoteDataSourceImpl(client: mockDioClient);
  });

  const tLocationModel = GeofenceLocationModel(
    id: '1',
    name: 'Office',
    latitude: 23.8103,
    longitude: 90.4125,
    radius: 100.0,
  );
  final tLocationJson = {
    'id': '1',
    'name': 'Office',
    'latitude': 23.8103,
    'longitude': 90.4125,
    'radius': 100.0,
  };

  group('getLocations', () {
    test('should return list of GeofenceLocationModel when response is 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/locations'),
            data: {'data': [tLocationJson]},
            statusCode: 200,
          ));

      final result = await dataSource.getLocations();

      expect(result.first.id, tLocationModel.id);
      expect(result.first.name, tLocationModel.name);
      expect(result.first.latitude, tLocationModel.latitude);
      expect(result.first.longitude, tLocationModel.longitude);
      expect(result.first.radius, tLocationModel.radius);
    });

    test('should throw ServerException when response code is not 200', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/locations'),
            statusCode: 500,
          ));

      final call = dataSource.getLocations();

      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('saveLocation', () {
    test('should complete normally when response is 200 or 201', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/locations'),
            statusCode: 201,
          ));

      await dataSource.saveLocation(tLocationModel);

      verify(() => mockDio.post('/locations', data: tLocationModel.toJson())).called(1);
    });
  });

  group('deleteLocation', () {
    test('should complete normally when response is 200 or 204', () async {
      when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/locations/1'),
            statusCode: 200,
          ));

      await dataSource.deleteLocation('1');

      verify(() => mockDio.delete('/locations/1')).called(1);
    });
  });
}
