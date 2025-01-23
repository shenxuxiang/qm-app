import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:qm/common/base.dart';
import 'package:qm/utils/index.dart';

class ConnectDevice extends BasePage {
  const ConnectDevice({super.key, required super.title});

  @override
  BasePageState<ConnectDevice> createState() => _ConnectDeviceState();
}

class _ConnectDeviceState extends BasePageState<ConnectDevice> {
  handleGoBack() {
    History.pop();
  }

  @override
  void initState() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
    super.initState();
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
      body: StreamBuilder<BluetoothAdapterState>(
          stream: FlutterBluePlus.adapterState,
          initialData: BluetoothAdapterState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothAdapterState.on) {
              return const FindDevicesScreen();
            }
            return BluetoothOffScreen(adapterState: state);
          }),
    );
  }
}
