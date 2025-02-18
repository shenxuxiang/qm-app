import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart' as amapFlutterBase;

/// 截流函数
T throttle<T extends Function>(T callback, Duration delay) {
  Timer? timer;
  return ([dynamic arguments]) {
    timer ??= Timer(delay, () {
      timer = null;
      callback(arguments);
    });
  } as T;
}

/// 防抖函数
T debounce<T extends Function>(T callback, Duration delay) {
  Timer? timer;
  return ([dynamic arguments]) {
    timer?.cancel();
    timer = Timer(delay, () {
      callback(arguments);
    });
  } as T;
}

/// 将日期类型的对象进行格式化（'YYYY-MM-DD'） 年-Y、月-M、日-D
formatDateTime(DateTime date, [String format = 'YYYY-MM-DD HH:mm:ss']) {
  var matches = RegExp(r'Y').allMatches(format);
  var year = date.year.toString();
  year = year.substring(4 - matches.length);

  matches = RegExp(r'M').allMatches(format);
  var month = date.month.toString().padLeft(2, '0');
  month = month.substring(2 - matches.length);

  matches = RegExp(r'D').allMatches(format);
  var day = date.day.toString().padLeft(2, '0');
  day = day.substring(2 - matches.length);

  matches = RegExp(r'H').allMatches(format);
  var hour = date.hour.toString().padLeft(2, '0');
  hour = hour.substring(2 - matches.length);

  matches = RegExp(r'm').allMatches(format);
  var minute = date.minute.toString().padLeft(2, '0');
  minute = minute.substring(2 - matches.length);

  matches = RegExp(r's').allMatches(format);
  var second = date.second.toString().padLeft(2, '0');
  second = second.substring(2 - matches.length);

  String string = format.replaceFirst(RegExp(r'Y+'), year);
  string = string.replaceFirst(RegExp(r'M+'), month);
  string = string.replaceFirst(RegExp(r'D+'), day);
  string = string.replaceFirst(RegExp(r'H+'), hour);
  string = string.replaceFirst(RegExp(r'm+'), minute);
  string = string.replaceFirst(RegExp(r's+'), second);

  return string;
}

/// 获取两个点位之间的实际距离
getDistanceBetween(LatLng position, LatLng prevPosition) {
  return amapFlutterBase.AMapTools.distanceBetween(
    amapFlutterBase.LatLng(position.latitude, position.longitude),
    amapFlutterBase.LatLng(prevPosition.latitude, prevPosition.longitude),
  );
}
