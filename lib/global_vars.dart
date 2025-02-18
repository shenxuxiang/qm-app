import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 全局变量
class GlobalVars {
  /// 获取 BuildContext
  static BuildContext? context;

  /// 用户密码验证规则
  /// 必须包含数字、字母、以及特殊符号【. , ? _ ` ! @ # $ % ^ & * \ - = + ( ) [ ] { }】
  static final RegExp userPasswordPattern = RegExp(
      r'^(?=.*\d+)(?=.*[a-zA-Z]+)(?=.*[.,?_`!@#$%^&*\-=+()\[\]{}]+)[.,?_`!@#$%^&*\-=+()\[\]{}0-9a-zA-Z]{6,18}');

  static final RegExp phonePattern = RegExp(r'^1[345789][0-9]{9}$');

  static final List<String> tiandituImgSubdomains = ['1', '2', '3', '4'];

  static final List<String> tiandituCiaSubdomains = ['1', '2', '3', '4'];

  /// 天地图瓦片服务-影像底图
  static final String tiandituImg =
      'https://webst0{s}.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}'; // 'https://t{s}.tianditu.gov.cn/img_w/wmts?tk=49e687be3d835676e4cd1f15a24c1aef&SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}';

  /// 天地图瓦片服务-影像注记
  static final String tiandituCia =
      'https://webst0{s}.is.autonavi.com/appmaptile?style=8&x={x}&y={y}&z={z}'; // 'https://t{s}.tianditu.gov.cn/cia_w/wmts?tk=49e687be3d835676e4cd1f15a24c1aef&SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cia&STYLE=default&TILEMATRIXSET=w&FORMAT=tiles&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}';
}
