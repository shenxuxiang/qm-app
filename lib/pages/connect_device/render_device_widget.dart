import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:qm/components/button_widget.dart';
import 'package:qm/models/connect_device_models.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RenderDeviceWidget extends StatefulWidget {
  final BluetoothDevice device;
  final AdvertisementData advertisementData;

  const RenderDeviceWidget({
    super.key,
    required this.device,
    required this.advertisementData,
  });

  @override
  State<RenderDeviceWidget> createState() => _RenderDeviceWidgetState();
}

class _RenderDeviceWidgetState extends State<RenderDeviceWidget> {
  bool _isLoading = false;
  late final StreamSubscription _connectionStateSubscription;
  BluetoothConnectionState _connectState = BluetoothConnectionState.disconnected;

  Future<void> handleDisconnectDevice() async {
    final connectDeviceModels = Get.find<ConnectDeviceModels>();
    await widget.device.disconnect(timeout: 10);
    connectDeviceModels.onChangedDevice(null);
  }

  Future<void> handleConnectDevice() async {
    final connectDeviceModels = Get.find<ConnectDeviceModels>();
    final connectedDevice = connectDeviceModels.connectedDevice.value;

    /// 先断开，再连接
    await connectedDevice?.disconnect(timeout: 10);
    connectDeviceModels.onChangedDevice(null);
    await widget.device.connect(timeout: const Duration(seconds: 10));
    connectDeviceModels.onChangedDevice(widget.device);
  }

  handleConnectOrDisConnect() async {
    if (_isLoading) return;
    _isLoading = true;

    Loading.show(
      text: _connectState == BluetoothConnectionState.connected ? '正在断开设备...' : '正在连接设备...',
    );

    Timer? timer;

    try {
      final connectDeviceModels = Get.find<ConnectDeviceModels>();

      void onTimeout() {
        throw Exception('操作超时～');
      }

      /// 设定一个操作超时的时间：10s
      timer = Timer(const Duration(seconds: 10), () {
        timer = null;
        connectDeviceModels.connectedDevice.value?.disconnect();
        widget.device.disconnect();
        onTimeout();
      });

      if (_connectState == BluetoothConnectionState.connected) {
        await handleDisconnectDevice();
      } else {
        await handleConnectDevice();
      }

      timer?.cancel();
      Loading.hide();
    } catch (error) {
      timer?.cancel();
      Loading.hide();
      Toast.show('操作超时～');
    }
  }

  @override
  void initState() {
    /// 监听设备的连接状态
    _connectionStateSubscription = widget.device.connectionState.listen(
      (BluetoothConnectionState state) {
        setState(() {
          _isLoading = false;
          _connectState = state;
        });
      },
      onError: (error, stack) {
        debugPrint('$error');
        debugPrint('$stack');
      },
      onDone: () => _connectionStateSubscription.cancel(),
      cancelOnError: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String deviceName = widget.advertisementData.advName.isNotEmpty
        ? widget.advertisementData.advName
        : widget.device.remoteId.str;

    return Container(
      width: double.infinity,
      height: 100.w,
      margin: EdgeInsets.only(bottom: 15.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [BoxShadow(offset: Offset(5, 5), color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16.w, color: Colors.black, height: 1),
                ),
              ],
            ),
          ),
          ButtonWidget(
            width: 120.w,
            type: 'default',
            onPressed: handleConnectOrDisConnect,
            ghost: _connectState == BluetoothConnectionState.connected ? false : true,
            text: _connectState == BluetoothConnectionState.connected ? 'DISCONNECT' : 'CONNECT',
          ),
        ],
      ),
    );
  }
}
