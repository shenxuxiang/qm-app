import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:qmnj/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:amap_map/amap_map.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:x_amap_base/x_amap_base.dart';
import 'package:qmnj/entity/location_info.dart';
import 'package:qmnj/entity/driver_work_params.dart';
import 'package:qmnj/models/connect_device_models.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  /// 倾斜度（范围从0到360度）、缩放级别（最大 20）、指向的方向（范围从0到360度）
  final double _tilt = 10;
  final double _zoom = 17.5;
  final double _bearing = 0;
  final GlobalKey _globalKey = GlobalKey();

  /// 选择设备的特征
  BluetoothCharacteristic? _selectedCharacteristic;

  /// 作业起点的标记
  final _startPointMarkerIcon = BitmapDescriptor.fromIconPath('assets/images/start-point.png');

  /// 定位蓝点的自定义 Icon
  final _myLocationStyleOptionsIcon = BitmapDescriptor.fromIconPath('assets/images/location.png');

  /// 定位蓝点
  MyLocationStyleOptions? _myLocationStyleOptions;

  ///  停止监听用户定位
  UnListenUserLocation? _unListenUserLocation;

  /// 初始坐标
  CameraPosition? _initialPosition;

  /// 用户作业轨迹路线
  Set<Polyline> _polyLineMaps = {};

  /// mark 标记（只标记一个作业起点）
  Set<Marker> _markerMaps = {};

  /// 作业轨迹（要发送给后端的）
  List<Map<String, dynamic>> _driverWorkTrace = [];

  /// 地图控制器
  AMapController? _mapController;

  /// 作业里程数（米）
  double _driverWorkMeter = 0;

  /// 获取用户的当前位置
  Future<void> getUserLocation() async {
    LocationInfo? locationInfo = await userLocation.getUserLocation();
    if (locationInfo != null) {
      LatLng position = LatLng(locationInfo.latitude, locationInfo.longitude);

      setState(() {
        _initialPosition = CameraPosition(
          zoom: _zoom,
          tilt: _tilt,
          target: position,
          bearing: _bearing,
        );
        _mapController?.moveCamera(CameraUpdate.newCameraPosition(_initialPosition!));
      });
    }
  }

  /// 地图创建成功的回调，更新 _mapController
  _onMapCreated(AMapController controller) {
    setState(() {
      if (_initialPosition != null) {
        controller.moveCamera(CameraUpdate.newCameraPosition(_initialPosition!));
      }
      _mapController = controller;
    });
  }

  /// 开始作业
  handleStartWork() {
    setState(() {
      /// 清空作业轨迹
      _driverWorkTrace = [];

      /// 设置定位蓝点
      _myLocationStyleOptions = MyLocationStyleOptions(
        true,
        icon: _myLocationStyleOptionsIcon,
        circleFillColor: Colors.transparent,
        circleStrokeColor: Colors.transparent,
      );
    });

    /// 实时监听用户位置
    _unListenUserLocation = userLocation.listenUserLocation((LocationInfo locationInfo) {
      LatLng point = LatLng(locationInfo.latitude, locationInfo.longitude);
      List<LatLng> points = _polyLineMaps.isNotEmpty ? List.of(_polyLineMaps.first.points) : [];

      /// 计算两个点之间的距离
      final distance = points.isEmpty ? 0 : AMapTools.distanceBetween(points.last, point);

      /// 更新用户轨迹线
      points.add(point);

      /// 添加作业轨迹
      _driverWorkTrace.add({
        'latitude': locationInfo.latitude,
        'longitude': locationInfo.longitude,
        'createTime': locationInfo.locationTime,
      });
      Polyline polyline = _polyLineMaps.isNotEmpty
          ? _polyLineMaps.first.copyWith(pointsParam: points)
          : Polyline(
              width: 6.w,
              points: points,
              capType: CapType.round,
              color: Color(0xFFFF8800),
            );

      setState(() {
        // 地图上只展示起点 Marker，我们将开始监听获取的第一个点作为【作业起点】
        if (_markerMaps.isEmpty) {
          _markerMaps = {Marker(position: point, icon: _startPointMarkerIcon!)};
        }
        _polyLineMaps = {polyline};

        /// 实时更新用户位置
        _mapController?.moveCamera(CameraUpdate.newLatLng(point));

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
        // 隐藏定位蓝点
        _myLocationStyleOptions = MyLocationStyleOptions(false);
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
  }

  @override
  Widget build(BuildContext context) {
    /// 需在 AMapWidget 使用前调用该方法。
    AMapInitializer.init(context);
    return Scaffold(
      appBar: AppBar(title: Text('农机作业')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: AMapWidget(
              key: _globalKey,
              markers: _markerMaps,
              polylines: _polyLineMaps,
              mapType: MapType.satellite,
              onMapCreated: _onMapCreated,
              myLocationStyleOptions: _myLocationStyleOptions,
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
              onPressed: () => handleTapStartOrEndButton(context),
              child: const Placeholder(),
            ),
          ),
        ],
      ),
    );
  }
}
