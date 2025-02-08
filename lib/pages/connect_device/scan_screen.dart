import 'dart:async';
import 'package:get/get.dart';
import 'render_device_widget.dart';
import 'package:flutter/material.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:qm/models/connect_device_models.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  late final StreamSubscription _scanStreamSubscription;
  late final StreamSubscription _scanResultStreamSubscription;

  /// 下拉刷新，重新扫描
  Future<void> handleRefresh() async {
    if (_isScanning == false) {
      await handleStartScan();
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // handleStopScan() async {
  //   try {
  //     FlutterBluePlus.stopScan();
  //   } catch (error, stack) {
  //     debugPrint('$error');
  //     debugPrint('$stack');
  //   }
  // }

  handleStartScan() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      List<Guid> withServices = [Guid('180f')];
      await FlutterBluePlus.systemDevices(withServices);
    } catch (error, stack) {
      debugPrint('$error');
      debugPrint('$stack');
    }

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    } catch (error, stack) {
      debugPrint('$error');
      debugPrint('$stack');
    }
  }

  handleConfirm() async {
    Get.find<ConnectDeviceModels>().onChangedDriverWorkParams(Get.arguments);
    Get.until((route) => route.settings.name == '/');
  }

  @override
  void initState() {
    /// 监听扫描
    _scanStreamSubscription = FlutterBluePlus.isScanning.listen(
      (bool value) {
        if (mounted) {
          if (value) {
            utils.Loading.show(text: '正在扫描设备');
          } else {
            utils.Loading.hide();
          }
          setState(() => _isScanning = value);
        }
      },
      onError: (error, stack) {
        debugPrint('$error');
        debugPrint('$stack');
      },
      onDone: () => _scanStreamSubscription.cancel(),
      cancelOnError: true,
    );

    /// 对扫描的结果进行实时监听
    _scanResultStreamSubscription = FlutterBluePlus.scanResults.listen(
      (List<ScanResult> value) {
        if (mounted) {
          setState(() {
            _scanResults = value.where((ScanResult item) {
              final advertisementData = item.advertisementData;
              return advertisementData.connectable &&
                  (advertisementData.advName.isNotEmpty || item.device.remoteId.str.isNotEmpty);
            }).toList();
          });
        }
      },
      onError: (error, stack) {
        debugPrint('$error');
        debugPrint('$stack');
      },
      onDone: () => _scanResultStreamSubscription.cancel(),
      cancelOnError: true,
    );

    handleStartScan();
    super.initState();
  }

  @override
  void dispose() {
    _scanStreamSubscription.cancel();
    _scanResultStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
          children: <Widget>[
            for (ScanResult item in _scanResults)
              RenderDeviceWidget(
                device: item.device,
                advertisementData: item.advertisementData,
              ),
          ],
        ),
      ),
      floatingActionButton: GetX<ConnectDeviceModels>(
        builder: (controller) {
          final connectedDevice = controller.connectedDevice;
          return StreamBuilder(
            stream: connectedDevice.value?.connectionState,
            builder: (context, snapshot) {
              bool isConnected =
                  snapshot.hasData && snapshot.data == BluetoothConnectionState.connected;
              return FloatingActionButton(
                shape: CircleBorder(),
                onPressed: () {
                  if (isConnected) handleConfirm();
                },
                backgroundColor: isConnected ? Theme.of(context).primaryColor : Color(0xFFCCCCCC),
                child: Text(
                  '开始',
                  style: TextStyle(
                    fontSize: 14.w,
                    color: isConnected ? Colors.white : Color(0xFF999999),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
