import 'package:permission_handler/permission_handler.dart';

/// 获取用户定位权限
Future<bool> requestLocationPermission() async {
  PermissionStatus status = await Permission.location.request();
  if (status == PermissionStatus.granted) {
    return true;
  } else {
    return false;
  }
}
