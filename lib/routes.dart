import 'package:flutter/material.dart';
import 'package:qm/pages/home.dart' show HomePage;
import 'package:qm/utils/index.dart' show GlobalVars;
import 'package:qm/pages/login/index.dart' show LoginPage;
import 'package:qm/pages/register/index.dart' show RegisterPage;

Map<String, WidgetBuilder> _generateRoutes(Map<String, Widget> routes) {
  Map<String, WidgetBuilder> result = {};

  for (MapEntry<String, Widget> entry in routes.entries) {
    result[entry.key] = (BuildContext context) {
      GlobalVars.context = context;
      return entry.value;
    };
  }

  return result;
}

final routes = _generateRoutes({
  '/': const HomePage(title: '阡陌农服'),
  '/login': const LoginPage(title: '登录'),
  '/register': const RegisterPage(title: '注册'),
});
