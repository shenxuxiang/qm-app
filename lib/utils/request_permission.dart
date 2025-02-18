import 'package:permission_handler/permission_handler.dart';

/// 获取用户定位权限
Future<bool> requestLocationPermission() async {
  bool isGranted = await Permission.location.request().isGranted;
  bool isAlwaysGranted = await Permission.locationAlways.request().isGranted;
  if (isGranted && isAlwaysGranted) {
    return true;
  } else {
    return false;
  }
}

/// 获取蓝牙权限
Future<bool> requestBluetoothPermission() async {
  bool isGrantedScan = await Permission.bluetoothScan.request().isGranted;
  bool isGrantedConnect = await Permission.bluetoothConnect.request().isGranted;
  if (isGrantedScan && isGrantedConnect) {
    return true;
  } else {
    return false;
  }
}
