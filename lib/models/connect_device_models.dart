import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:qm/entity/driver_work_params.dart';
import 'package:get/get.dart';

class ConnectDeviceModels extends GetxController {
  /// 连接设备
  final connectedDevice = Rx<BluetoothDevice?>(null);

  void onChangedDevice(BluetoothDevice? value) {
    connectedDevice.value = value;
  }

  /// 开始作业的请求参数
  final driverWorkParams = Rx<DriverWorkParams?>(null);

  void onChangedDriverWorkParams(DriverWorkParams? value) {
    driverWorkParams.value = value;
  }
}
