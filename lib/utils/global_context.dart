import 'package:flutter/material.dart';

/// 全局变量
class GlobalVars {
  /// 添加一个全局可访问的构建上下文
  static late BuildContext context;

  /// 用户密码验证规则
  /// 必须包含数字、字母、以及特殊符号【. , ? _ ` ! @ # $ % ^ & * \ - = + ( ) [ ] { }】
  static RegExp userPasswordPattern = RegExp(
      r'^(?=.*\d+)(?=.*[a-zA-Z]+)(?=.*[.,?_`!@#$%^&*\-=+()\[\]{}]+)[.,?_`!@#$%^&*\-=+()\[\]{}0-9a-zA-Z]{6,18}');

  static RegExp phonePattern = RegExp(r'^1[345789][0-9]{9}$');
}
