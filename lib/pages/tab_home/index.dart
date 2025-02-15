import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:qmnj/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/global_vars.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:qmnj/entity/position.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:qmnj/entity/driver_work_params.dart';
import 'package:qmnj/models/connect_device_models.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart' as amapFlutterBase;

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  final _mapController = MapController();

  final double _zoom = 16.75;
  final double _maxZoom = 18;

  /// 选择设备的特征
  BluetoothCharacteristic? _selectedCharacteristic;

  ///  停止监听用户定位
  UnListenUserLocation? _unListenUserLocation;

  /// 用户作业轨迹路线
  List<Polyline> _polyLineMaps = [];

  /// mark 标记（只标记一个作业起点）
  List<Marker> _markerMaps = [];

  /// 作业轨迹（要发送给后端的）
  List<Map<String, dynamic>> _driverWorkTrace = [];

  /// 作业里程数（米）
  double _driverWorkMeter = 0;

  /// 获取用户的当前位置
  Future<void> getUserLocation() async {
    Position? position = await userLocation.getUserLocation();
    if (position != null && context.mounted) {
      LatLng initialPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(initialPosition, _zoom);
    }
  }

  /// 开始作业
  handleStartWork() {
    setState(() {
      /// 清空作业轨迹
      _driverWorkTrace = [];
    });

    /// 实时监听用户位置
    _unListenUserLocation = userLocation.listenUserLocation((Position? position) {
      if (position == null) return;

      LatLng point = LatLng(position.latitude, position.longitude);
      List<LatLng> points = _polyLineMaps.isNotEmpty ? _polyLineMaps.elementAt(0).points : [];

      final distance = points.isEmpty
          ? 0
          : amapFlutterBase.AMapTools.distanceBetween(
              amapFlutterBase.LatLng(points.last.latitude, points.last.longitude),
              amapFlutterBase.LatLng(point.latitude, point.longitude),
            );

      /// 坐标过滤，如果相邻两个点位之间的间距大于 200 米，则认为这个点是无效的。
      if (distance > 200) return;

      /// 更新用户轨迹线
      points.add(point);

      /// 添加作业轨迹
      _driverWorkTrace.add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createTime': position.locationTime,
      });
      Polyline polyline = Polyline(
        points: points,
        strokeWidth: 6.w,
        color: Color(0xFFFF8800),
        strokeJoin: StrokeJoin.round,
      );

      /// 实时更新用户位置
      _mapController.moveAndRotate(point, _zoom, 0);
      setState(() {
        // 地图上只展示起点 Marker，我们将开始监听获取的第一个点作为【作业起点】
        if (_markerMaps.isEmpty) {
          _markerMaps = [Marker(point: point, child: Image.asset('assets/images/start-point.png'))];
        } else if (_markerMaps.length < 2) {
          _markerMaps.add(Marker(point: point, child: Image.asset('assets/images/location.png')));
        } else {
          _markerMaps.last = Marker(point: point, child: Image.asset('assets/images/location.png'));
        }

        _polyLineMaps = [polyline];
        _driverWorkMeter += distance;
      });
    });
  }

  /// 结束作业
  handleEndWork() async {
    final isEndDriveWork = await showAlertDialog(title: '是否停止作业？');
    if (isEndDriveWork != true) return;
    final connectDeviceModels = Get.find<ConnectDeviceModels>();
    try {
      await api.queryEndWork({'coordinates': _driverWorkTrace});

      /// 断开设备连接
      await connectDeviceModels.connectedDevice.value?.disconnect();
      // 取消监听用户定位
      await _unListenUserLocation!();

      setState(() {
        // 取消所有 Marker
        _markerMaps.clear();
        // 取消所有 Polyline
        _polyLineMaps.clear();
        // 作业里程数
        _driverWorkMeter = 0;
        _unListenUserLocation = null;
      });
      Toast.show('作业已停止');

      connectDeviceModels.onChangedDriverWorkParams(null);
      connectDeviceModels.onChangedDevice(null);
    } catch (error, stack) {
      Toast.show('操作异常');
      debugPrint('error: $error');
      debugPrint('stack: $stack');
    }
  }

  /// 点击开始/结束按钮
  handleTapStartOrEndButton(BuildContext context) {
    if (_unListenUserLocation == null) {
      /// 开始作业
      showAlertDialog(
        cancelText: '无设备',
        confirmText: '有设备',
        title: '请选择终端设备',
        onCancel: () async {
          await Get.toNamed('/work_type') as DriverWorkParams?;

          final driverWorkParams = Get.find<ConnectDeviceModels>().driverWorkParams.value;

          /// result 不为空，则开始作业，否则取消用户行为。
          if (driverWorkParams != null) {
            await api.queryDriverWork(driverWorkParams.toJson());
            handleStartWork();
          }
        },
        onConfirm: () async {
          /// 获取连接到的设备
          await Get.toNamed('/work_type', parameters: {'hasDevice': 'true'});

          final connectDeviceModels = Get.find<ConnectDeviceModels>();
          final connectedDevice = connectDeviceModels.connectedDevice.value;
          final driverWorkParams = connectDeviceModels.driverWorkParams.value;

          if (connectedDevice != null && driverWorkParams != null) {
            await api.queryDriverWork(driverWorkParams.toJson());

            /// 如果连接的设备不为空，则开始作业。并对设备进行监听，实时读取设备的数据。
            handleStartWork();
            handleDiscoverService(connectedDevice);
          }
        },
      );
    } else {
      /// 结束作业
      handleEndWork();
    }
  }

  /// 读取设备特征数据
  handleReadCharacteristicData() async {
    try {
      /// 读取设备的数据
      final subscription = _selectedCharacteristic!.lastValueStream.listen(
        (List<int> value) {
          debugPrint('setNotify: ${utf8.decode(value)}');
        },
        onError: (error, stack) {
          debugPrint('$error');
          debugPrint('$stack');
        },
        onDone: () {
          Get.find<ConnectDeviceModels>().connectedDevice.value?.disconnect();
        },
        cancelOnError: true,
      );

      final connectedDevice = Get.find<ConnectDeviceModels>().connectedDevice.value!;

      /// 当设备连接断开时，取消监听。
      connectedDevice.cancelWhenDisconnected(subscription);
      await _selectedCharacteristic!.setNotifyValue(true);
    } catch (error) {
      Toast.show('设备监听异常');
    }
  }

  /// 监听设备并读取设备返回的数据
  handleDiscoverService(BluetoothDevice connectedDevice) async {
    List<BluetoothService> bluetoothServices = await connectedDevice.discoverServices();
    for (BluetoothService item in bluetoothServices) {
      List<BluetoothCharacteristic> characteristics = item.characteristics;
      if (characteristics.isNotEmpty) _selectedCharacteristic = characteristics[0];

      /// 读取设备的数据
      handleReadCharacteristicData();
      return;
    }
  }

  @override
  void initState() {
    /// 获取用户的当前位置。
    getUserLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();

    /// 如果监听定位存在，则认为用户正在作业。此时需要关闭作业。
    if (_unListenUserLocation != null) api.queryEndWork({'coordinates': _driverWorkTrace});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('农机作业')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                crs: const Epsg3857(),
                initialZoom: _zoom,
                maxZoom: _maxZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: GlobalVars.tiandituImg,
                  subdomains: ['0', '1', '2', '3', '4', '5', '6', '7'],
                  userAgentPackageName: 'com.example.qmnj',
                ),
                TileLayer(
                  urlTemplate: GlobalVars.tiandituCia,
                  subdomains: ['0', '1', '2', '3', '4', '5', '6', '7'],
                  userAgentPackageName: 'com.example.qmnj',
                ),
                PolylineLayer(polylines: _polyLineMaps),
                MarkerLayer(markers: _markerMaps),
              ],
            ),
          ),

          /// 展示作业里程
          _unListenUserLocation == null
              ? SizedBox(width: 0, height: 0)
              : Positioned(
                  top: 50.w,
                  child: Container(
                    width: 260.w,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '作业里程（公里）',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 14.w,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          (_driverWorkMeter / 1000).toStringAsFixed(3),
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 24.w,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

          /// 作业开始/结束开关
          Positioned(
            bottom: 20,
            width: 90,
            height: 90,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(CircleBorder()),
                side: WidgetStateProperty.all(BorderSide(width: 6.w, color: Colors.white)),
                backgroundBuilder: (BuildContext context, _, __) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xff6f8bf6),
                          Color(0xff476bf3),
                        ],
                        stops: [0.2, 0.8],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _unListenUserLocation == null ? '开始' : '结束',
                      style: TextStyle(
                        fontSize: 16.w,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onPressed: () {
                handleTapStartOrEndButton(context);
              },
              child: const Placeholder(),
            ),
          ),
        ],
      ),
    );
  }
}
