import 'package:permission_handler/permission_handler.dart';

/// 获取用户定位权限
Future<bool> requestLocationPermission() async {
  bool isGranted = await Permission.location.request().isGranted;
  if (isGranted) {
    return true;
  } else {
    return false;
  }
}
