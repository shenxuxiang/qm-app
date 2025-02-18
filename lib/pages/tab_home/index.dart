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
import 'package:qmnj/common/background_location_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  StreamSubscription<dynamic>? _backgroundTaskSubscription;
  final _mapController = MapController();
  final double _zoom = 16.8;
  final double _maxZoom = 18.5;

  /// 选择设备的特征
  BluetoothCharacteristic? _selectedCharacteristic;

  ///  停止监听用户定位
  UnListenUserLocation? _unListenUserLocation;

  /// 用户作业轨迹路线
  List<Polyline> _polyLineMaps = [];

  /// mark 标记（只标记一个作业起点）
  List<Marker> _markerMaps = [];

  /// 作业里程数（米）
  double _workMileage = 0;

  /// 获取用户的当前位置
  Future<void> getUserLocation() async {
    Position? position = await userLocation.getUserLocation();
    if (position != null && context.mounted) {
      LatLng initialPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(initialPosition, _zoom);
    }
  }

  /// 开始作业
  handleStartWork([bool clearTrace = true]) async {
    if (clearTrace) {
      /// 清空作业轨迹、作业里程
      // await storage.reload();
      await storage.remove('User-Driver-Work-Mileage');
      await storage.remove('User-Driver-Work-Trace');
    }

    // await BackgroundLocationTask.start();

    /// 实时监听用户位置
    _unListenUserLocation = userLocation.listenUserLocation((Position position) async {
      LatLng point = LatLng(position.latitude, position.longitude);

      /// 更新后同步到主线程
      // await storage.reload();
      double workMileage = storage.getItem('User-Driver-Work-Mileage') ?? 0;
      List<dynamic> workTrace = storage.getItem('User-Driver-Work-Trace') ?? [];

      List<LatLng> points = workTrace.isNotEmpty
          ? [for (final trace in workTrace) LatLng(trace['latitude'], trace['longitude'])]
          : [];

      if (workTrace.isNotEmpty) {
        /// 算法过滤，通过时间、以及经纬度来过滤
        final trace = workTrace.last;
        final time1 = DateTime.parse(position.locationTime);
        final time2 = DateTime.parse(trace['createTime']);

        if (time1.compareTo(time2) <= 0) {
          return;
        } else if (trace['latitude'] == point.latitude && trace['longitude'] == point.longitude) {
          return;
        }

        /// 累计作业里程
        workMileage += getDistanceBetween(point, points.last);
      }

      /// 更新用户轨迹线
      points.add(point);
      workTrace.add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'createTime': position.locationTime,
      });
      storage.setItem('User-Driver-Work-Trace', workTrace);
      storage.setItem('User-Driver-Work-Mileage', workMileage);

      /// 实时更新用户位置
      _mapController.moveAndRotate(point, _zoom, 0);
      setState(() {
        /// 地图上只展示起点 Marker，我们将开始监听获取的第一个点作为【作业起点】
        if (_markerMaps.isEmpty) {
          _markerMaps = [Marker(point: point, child: Image.asset('assets/images/start-point.png'))];
        } else if (_markerMaps.length < 2) {
          _markerMaps.add(Marker(point: point, child: Image.asset('assets/images/location.png')));
        } else {
          _markerMaps.last = Marker(point: point, child: Image.asset('assets/images/location.png'));
        }

        /// 更新 Map 轨迹
        _polyLineMaps = [
          Polyline(
            points: points,
            strokeWidth: 6.w,
            color: Color(0xFFFF8800),
            strokeJoin: StrokeJoin.round,
          )
        ];

        /// 更新 UI 界面作业里程
        _workMileage = workMileage;
      });
    });
  }

  /// 结束作业
  handleEndWork([bool isConfirm = false]) async {
    final isEndDriveWork = !isConfirm ? await showAlertDialog(title: '是否停止作业？') : true;
    if (isEndDriveWork != true) return;
    final connectDeviceModels = Get.find<ConnectDeviceModels>();
    try {
      // await BackgroundLocationTask.stop();
      final workTrace = storage.getItem('User-Driver-Work-Trace') ?? [];
      final workMileage = storage.getItem('User-Driver-Work-Mileage') ?? 0;

      await api.queryEndWork({
        'coordinates': workTrace,
        'mileage': (workMileage / 1000).toStringAsFixed(2),
      });

      /// 断开设备连接
      await connectDeviceModels.connectedDevice.value?.disconnect();
      // 取消监听用户定位
      if (_unListenUserLocation != null) await _unListenUserLocation!();

      setState(() {
        // 取消所有 Marker
        _markerMaps.clear();
        // 取消所有 Polyline
        _polyLineMaps.clear();
        // 作业里程数
        _workMileage = 0;
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
            try {
              await api.queryDriverWork(driverWorkParams.toJson());
              await handleStartWork();
            } on DioException catch (err) {
              /// 500 表示之前有未结束的作业。
              if (err.response!.data['code'] == 500) {
                await api.queryEndWork({'coordinates': []});
                await Future.delayed(Duration(milliseconds: 1500));
                Toast.show('可以重新开始作业');
              }
            }
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
            await handleStartWork();
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

  /// 监听后台任务
  // listenBackgroundTask(dynamic data) {
  //   debugPrint('收到通知了: $data');
  //   BackgroundLocationTask.start();
  // }

  @override
  void initState() {
    /// 获取用户的当前位置。
    getUserLocation();
    super.initState();
    // BackgroundLocationTask.listen(listenBackgroundTask);
    api.queryDriverWorkStatus({}).then((resp) async {
      if (!resp.data) {
        showAlertDialog(
          title: '作业提示',
          content: Text('用户当前存在一个未结束的作业，是否继续作业'),
          onConfirm: () {
            handleStartWork(false);
          },
          onCancel: () {
            handleEndWork(true);
          },
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
    // BackgroundLocationTask.remove(listenBackgroundTask);
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
                  subdomains: GlobalVars.tiandituImgSubdomains,
                  userAgentPackageName: 'com.example.qmnj',
                ),
                TileLayer(
                  urlTemplate: GlobalVars.tiandituCia,
                  subdomains: GlobalVars.tiandituCiaSubdomains,
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
                          (_workMileage / 1000).toStringAsFixed(2),
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
