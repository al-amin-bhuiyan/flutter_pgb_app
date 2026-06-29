import 'package:permission_handler/permission_handler.dart';

abstract class PermissionManager {
  Future<bool> requestLocationPermissions();
  Future<bool> checkLocationPermissions();
}

class PermissionManagerImpl implements PermissionManager {
  @override
  Future<bool> requestLocationPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final backgroundStatus = await Permission.locationAlways.request();
      return backgroundStatus.isGranted;
    }
    return false;
  }

  @override
  Future<bool> checkLocationPermissions() async {
    final status = await Permission.location.status;
    final backgroundStatus = await Permission.locationAlways.status;
    return status.isGranted && backgroundStatus.isGranted;
  }
}
