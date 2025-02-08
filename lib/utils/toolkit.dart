import 'dart:async';

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
