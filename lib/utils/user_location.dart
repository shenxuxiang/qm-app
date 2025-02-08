import 'dart:async';
import 'request_permission.dart';
import 'package:flutter/material.dart';
import 'package:qm/common/amap_config.dart';
import 'package:qm/entity/location_info.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';

class UserLocation {
  late final bool _hasPermission;
  static final Map<String, UserLocation> _cache = {};
  final String? _iosKey = AmapConfig.amapApiKeys.iosKey;
  final String? _androidKey = AmapConfig.amapApiKeys.androidKey;

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
      // AMapFlutterLocation.setApiKey(_androidKey!, _iosKey!);
      _hasPermission = await requestLocationPermission();
      return _hasPermission;
    } catch (err, stack) {
      debugPrint('error: $err');
      debugPrint('stack: $stack');
      return false;
    }
  }

  /// 获取用户定位
  Future<LocationInfo?> getUserLocation() async {
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

      await st.forEach((Map<String, dynamic> result) {
        data = result;
      });

      locationPlugin.stopLocation();
      locationPlugin.destroy();
      return LocationInfo.fromJson(data);
    } else {
      return null;
    }
  }

  UnListenUserLocation? listenUserLocation(Function(LocationInfo locationInfo) listen) {
    if (_hasPermission) {
      final locationPlugin = AMapFlutterLocation();
      final listener = locationPlugin.onLocationChanged().listen((Map<String, dynamic> result) {
        listen(LocationInfo.fromJson(result));
      });

      ///将定位参数设置给定位插件
      locationPlugin.setLocationOption(AMapLocationOption(
        // 只监听一次
        onceLocation: false,
        // 是否需要地址信息，默认true
        needAddress: true,
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
