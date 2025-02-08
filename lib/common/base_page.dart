import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qm/utils/index.dart' as utils;

abstract class BasePage extends StatefulWidget {
  final String title;

  const BasePage({super.key, this.title = '阡陌农服'});
}

abstract class BasePageState<T extends BasePage> extends State<T> {
  /// author 表示该页面是否需要用户登录才能访问。
  final bool author;

  BasePageState({this.author = true}) {
    if (author) {
      /// 通过 Token 来判断用户是否已经登录
      final token = utils.storage.getItem<String>('User-Token');
      if (token?.isEmpty ?? true) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (Get.context?.mounted ?? false) {
            Get.offAllNamed('/login');
          }
        });
      }
    }
  }
}
