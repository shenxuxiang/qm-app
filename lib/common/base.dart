import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';

abstract class BasePage extends StatefulWidget {
  final String title;

  const BasePage({super.key, this.title = '阡陌农服'});
}

abstract class BasePageState<T extends StatefulWidget> extends State<T> {
  /// author 表示该页面是否需要用户登录才能访问。
  final bool author;

  BasePageState({this.author = true}) {
    if (author) {
      /// 通过 Token 来判断用户是否已经登录
      Storage.getItem('User-Token').then((token) {
        if (token?.isEmpty ?? true) {
          if (GlobalVars.context.mounted) {
            Navigator.of(GlobalVars.context).pushReplacementNamed('/login');
          }
        }
      });
    }
  }
}
