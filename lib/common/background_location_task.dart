import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qmnj/entity/position.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:qmnj/utils/index.dart';
import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

/// 后台定位
class BackgroundLocationTask {
  static final int _id = 9527;
  static final String isolateName = 'isolate_alarm_manager';

  /// 用于从后台 Isolate 到主 Isolate 进行通信的端口。
  static final ReceivePort receivePort = ReceivePort();
  static StreamSubscription? _streamSubscription;
  static final Set<Function> _listeners = {};

  static dispose() {
    _streamSubscription?.cancel();
    receivePort.close();
  }

  static init() async {
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'isolate_alarm_manager');
    _streamSubscription = receivePort.listen(
      (dynamic data) {
        for (final fn in _listeners) {
          fn.call(data);
        }
      },
      cancelOnError: true,
    );
    await AndroidAlarmManager.initialize();
  }

  static listen(Function fn) {
    _listeners.add(fn);
  }

  static remove(Function fn) {
    _listeners.remove(fn);
  }

  static Future<bool> start() async {
    final result = await AndroidAlarmManager.oneShot(
      Duration(seconds: 10),
      _id,
      _callback,
      exact: false,
      wakeup: true,
    );
    return result;
  }

  static Future<bool> stop() async {
    final result = await AndroidAlarmManager.cancel(_id);
    return result;
  }

  static _callback() async {
    debugPrint('helloworld =============1');
    SendPort? uiSendPort = IsolateNameServer.lookupPortByName('isolate_alarm_manager');
    uiSendPort?.send(true);

    Position? position;
    final locationPlugin = AMapFlutterLocation();
    final stream = locationPlugin.onLocationChanged().take(1);

    /// 将定位参数设置给定位插件
    locationPlugin.setLocationOption(AMapLocationOption(
      // 只监听一次
      onceLocation: true,
      // 是否需要地址信息，默认true
      needAddress: false,
      // iOS端是否允许系统暂停定位
      pausesLocationUpdatesAutomatically: false,
    ));

    locationPlugin.startLocation();
    await stream.forEach((Map<String, dynamic> data) {
      position = Position.fromJson(data);
      locationPlugin.stopLocation();
      locationPlugin.destroy();
    });

    if (position != null) {
      final storage = await SharedPreferences.getInstance();

      /// 同步主线程的数据
      await storage.reload();

      /// 作业轨迹
      String? jsonTrace = storage.getString('User-Driver-Work-Trace');
      final workTrace = jsonTrace == null ? [] : JsonDecoder().convert(jsonTrace);

      /// 作业里程（米）
      String? jsonMileage = storage.getString('User-Driver-Work-Mileage');
      double workMileage = jsonMileage == null ? 0 : JsonDecoder().convert(jsonMileage);

      final point = LatLng(position!.latitude, position!.longitude);

      if (workTrace.isNotEmpty) {
        /// 算法过滤，通过时间、以及经纬度来过滤
        final trace = workTrace.last;
        final time1 = DateTime.parse(position!.locationTime);
        final time2 = DateTime.parse(trace['createTime']);

        if (time1.compareTo(time2) <= 0) {
          return;
        } else if (trace['latitude'] == point.latitude && trace['longitude'] == point.longitude) {
          return;
        }

        final lastPosition = workTrace.last;
        workMileage += getDistanceBetween(
          point,
          LatLng(lastPosition['latitude'], lastPosition['longitude']),
        );
      }
      //
      // /// 添加作业轨迹
      // workTrace.add({
      //   'latitude': 31.1,
      //   'longitude': 118.1,
      //   'createTime': position!.locationTime,
      // });

      /// 添加作业轨迹
      workTrace.add({
        'latitude': position!.latitude,
        'longitude': position!.longitude,
        'createTime': position!.locationTime,
      });

      await storage.setString('User-Driver-Work-Trace', JsonEncoder().convert(workTrace));
      await storage.setString('User-Driver-Work-Mileage', JsonEncoder().convert(workMileage));

      debugPrint(storage.getString('User-Driver-Work-Trace'));
      debugPrint(storage.getString('User-Driver-Work-Mileage'));
    }
  }
}
