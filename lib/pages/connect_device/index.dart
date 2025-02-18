import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:qmnj/common/base_page.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/utils/index.dart';
import 'bluetooth_off_screen.dart';
import 'package:get/get.dart';
import 'scan_screen.dart';
import 'dart:async';

class ConnectDevice extends BasePage {
  const ConnectDevice({super.key, required super.title});

  @override
  BasePageState<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends BasePageState<ConnectDevice> {
  BluetoothAdapterState? _adapterState;
  late final StreamSubscription _adapterStateSubscription;

  handleGoBack() {
    Get.back();
  }

  @override
  void initState() {
    /// 获取上一个页面传入的数据。
    super.initState();

    /// 监听蓝牙的连接状态
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      (BluetoothAdapterState state) {
        setState(() => _adapterState = state);
      },
      onError: (error, stack) {
        debugPrint('$error');
        debugPrint('$stack');
      },
      onDone: () => _adapterStateSubscription.cancel(),
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white, size: 22.w),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        leading: GestureDetector(onTap: handleGoBack, child: Icon(QmIcons.back)),
      ),

      /// 蓝牙是否已经连接
      body: _adapterState == BluetoothAdapterState.on ? ScanScreen() : BluetoothOffScreen(),
    );
  }
}
