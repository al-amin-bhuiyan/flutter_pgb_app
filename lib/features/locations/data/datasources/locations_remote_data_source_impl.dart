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
    return _client.getList<GeofenceLocationModel>(
      path: '/locations',
      fromJson: GeofenceLocationModel.fromJson,
    );
  }

  @override
  Future<void> saveLocation(GeofenceLocationModel location) async {
    await _client.post<dynamic>(
      path: '/locations',
      data: location.toJson(),
      fromJson: (data) => data,
    );
  }

  @override
  Future<void> deleteLocation(String id) async {
    await _client.delete(
      path: '/locations/$id',
    );
  }
}
