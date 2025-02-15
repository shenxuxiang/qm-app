import 'dart:math';
import 'dart:async';
import 'request_permission.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/entity/position.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';

class _CoordinateConverter {
  static const double pi = 3.1415926535897932384626;
  static const double a = 6378245.0; // 长半轴（GCJ-02 使用）
  static const double ee = 0.00669342162296594323; // 偏心率平方

  // GCJ-02 转 WGS-84
  static List<double> gcj02ToWgs84(double lng, double lat) {
    if (_outOfChina(lng, lat)) {
      return [lng, lat];
    }
    double dLng = _transformLng(lng - 105.0, lat - 35.0);
    double dLat = _transformLat(lng - 105.0, lat - 35.0);
    final radLat = lat / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    final sqrtMagic = sqrt(magic);
    dLng = (dLng * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    return [lng - dLng, lat - dLat];
  }

  static bool _outOfChina(double lng, double lat) {
    return !(lng > 73.66 && lng < 135.05 && lat > 3.86 && lat < 53.55);
  }

  static double _transformLng(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
  }

  static double _transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }
}

class UserLocation {
  late final bool _hasPermission;
  static final Map<String, UserLocation> _cache = {};

  UserLocation._internal();

  factory UserLocation() {
    return _cache.putIfAbsent('User_Location', () => UserLocation._internal());
  }

  Future<bool> init() async {
    try {
      /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作<br>
      /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy<br>
      /// <b>必须保证在调用定位功能之前调用，建议首次启动 Ap p时弹出《隐私政策》并取得用户同意</b><br>
      /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy
      /// [hasContains] 隐私声明中是否包含高德隐私政策说明<br>
      /// [hasShow] 隐私权政策是否弹窗展示告知用户<br>
      AMapFlutterLocation.updatePrivacyShow(true, true);

      /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作<br>
      /// 高德SDK合规使用方案请参考官网地址：https://lbs.amap.com/news/sdkhgsy<br>
      /// <b>必须保证在调用定位功能之前调用, 建议首次启动App时弹出《隐私政策》并取得用户同意</b><br>
      /// [hasAgree] 隐私权政策是否已经取得用户同意<br>
      AMapFlutterLocation.updatePrivacyAgree(true);
      _hasPermission = await requestLocationPermission();
      return _hasPermission;
    } catch (err, stack) {
      debugPrint('error: $err');
      debugPrint('stack: $stack');
      return false;
    }
  }

  /// 获取用户定位
  Future<Position?> getUserLocation() async {
    if (_hasPermission) {
      final locationPlugin = AMapFlutterLocation();
      final st = locationPlugin.onLocationChanged().take(1);

      ///将定位参数设置给定位插件
      locationPlugin.setLocationOption(AMapLocationOption(
        // 只监听一次
        onceLocation: true,
        // 是否需要地址信息，默认true
        needAddress: true,
        // iOS端是否允许系统暂停定位
        pausesLocationUpdatesAutomatically: false,
      ));
      locationPlugin.startLocation();
      Map<String, dynamic> data = {};
      await st.forEach((Map<String, dynamic> result) => data = result);
      locationPlugin.stopLocation();
      locationPlugin.destroy();
      List<double> wgs84 = _CoordinateConverter.gcj02ToWgs84(data['longitude'], data['latitude']);
      data['longitude'] = wgs84[0];
      data['latitude'] = wgs84[1];
      return Position.fromJson(data);
    } else {
      return null;
    }
  }

  UnListenUserLocation? listenUserLocation(Function(Position locationInfo) listen) {
    if (_hasPermission) {
      final locationPlugin = AMapFlutterLocation();
      final listener = locationPlugin.onLocationChanged().listen((Map<String, dynamic> data) {
        List<double> wgs84 = _CoordinateConverter.gcj02ToWgs84(data['longitude'], data['latitude']);
        data['longitude'] = wgs84[0];
        data['latitude'] = wgs84[1];
        listen(Position.fromJson(data));
      });

      ///将定位参数设置给定位插件
      locationPlugin.setLocationOption(AMapLocationOption(
        // 只监听一次
        onceLocation: false,
        // 是否需要地址信息，默认true
        needAddress: true,
        // 每 4 秒间隔
        locationInterval: 4000,
        // iOS端是否允许系统暂停定位
        pausesLocationUpdatesAutomatically: false,
      ));

      locationPlugin.startLocation();

      Future<bool> unListen() async {
        try {
          await listener.cancel();
          locationPlugin.stopLocation();
          locationPlugin.destroy();
          return true;
        } catch (err) {
          return false;
        }
      }

      return unListen;
    } else {
      return null;
    }
  }
}

typedef UnListenUserLocation = Future<bool> Function();

final userLocation = UserLocation();
