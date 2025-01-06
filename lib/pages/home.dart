import 'dart:async';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:qm/common/amap_config.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:qm/common/base.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';

class HomePage extends BasePage {
  const HomePage({super.key, super.title});

  @override
  BasePageState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BasePageState<HomePage> {
  /// 初始坐标
  CameraPosition? _initialPosition;

  /// mark 标记
  final Set<Marker> _markerMaps = {};

  /// 地图控制器
  late final AMapController _mapController;

  /// 定位插件
  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();

  /// 定位监听器
  late final StreamSubscription<Map<String, Object>> _locationListener;

  _HomePageState({super.author = true});

  /// 获取用户定位权限
  Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.location.request();

    debugPrint('status: $status');
    if (status == PermissionStatus.denied) {
      return false;
    } else {
      return true;
    }
  }

  /// 设置定位参数
  void _setLocationOption() {
    AMapLocationOption locationOption = AMapLocationOption(
      // 只监听一次
      onceLocation: true,
      // 是否需要地址信息，默认true
      needAddress: false,
      // iOS端是否允许系统暂停定位
      pausesLocationUpdatesAutomatically: false,
    );

    ///将定位参数设置给定位插件
    _locationPlugin.setLocationOption(locationOption);
  }

  /// 开始定位
  void _startLocation() {
    _setLocationOption();
    _locationPlugin.startLocation();
  }

  /// 停止定位
  void _stopLocation() {
    _locationPlugin.stopLocation();
  }

  /// 地图初始化
  initialMapLocation() async {
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.setApiKey("9eb2423fb48ec22702d79b1b450443e5", "your_ios_api_key");

    /// 用户允许定位
    if (await requestPermission()) {
      /// 注册定位结果监听
      _locationListener = _locationPlugin.onLocationChanged().listen((Map<String, dynamic> result) {
        _stopLocation();
        double? lat = result['latitude'];
        double? lon = result['longitude'];
        LatLng position =
            lat != null && lon != null ? LatLng(lat, lon) : LatLng(39.909187, 116.397451);
        Marker marker = Marker(
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        setState(() {
          _markerMaps.add(marker);
          _initialPosition = CameraPosition(zoom: 16, target: position);
        });
      });

      _startLocation();
    }
  }

  /// 地图创建成功的回调
  _onMapCreated(AMapController controller) {
    _mapController = controller;
  }

  @override
  void initState() {
    initialMapLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // 移除定位监听
    _locationListener.cancel();
    // 销毁定位
    _locationPlugin.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: _initialPosition == null
          ? null
          : AMapWidget(
              mapType: MapType.satellite,
              markers: _markerMaps,
              onMapCreated: _onMapCreated,
              apiKey: AmapConfig.amapApiKeys,
              initialCameraPosition: _initialPosition!,
              privacyStatement: AmapConfig.amapPrivacyStatement,
            ),
    );
  }
}
