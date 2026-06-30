import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/geofence_location_model.dart';
import 'locations_remote_data_source.dart';

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  final DioClient _client;

  LocationsRemoteDataSourceImpl({
    required DioClient client,
  }) : _client = client;

  @override
  Future<List<GeofenceLocationModel>> getLocations() async {
    try {
      final response = await _client.dio.get('/locations');

      if (response.statusCode == 200) {
        final dataMap = response.data as Map<String, dynamic>;
        final list = dataMap['data'] as List<dynamic>;
        return list
            .map((item) => GeofenceLocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveLocation(GeofenceLocationModel location) async {
    try {
      final response = await _client.dio.post(
        '/locations',
        data: location.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      final response = await _client.dio.delete('/locations/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
