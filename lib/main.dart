import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:qm/models/main.dart';
import 'package:qm/utils/index.dart';
import 'package:qm/routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => MainModels(context)),
      ],
      child: const QmApp(),
    ),
  );
}

class QmApp extends StatelessWidget {
  const QmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      /// UI 设计稿尺寸
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'QM-APP',
        theme: ThemeData(
          // 按钮样式定义
          buttonTheme: ButtonThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xff476bf3),
              // 配置 ButtonWidget.type == 'primary' 的主题色。与全局主题色一致。
              primary: Color(0xff476bf3),
              // 配置 ButtonWidget.type == 'default' 时的背景和边框色。
              secondary: Color(0xffbfbfbf),
            ),
            // 按钮的形状
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          useMaterial3: true,
          // 全局主题色，
          primaryColor: Color(0xff476bf3),
          // 全局禁用的颜色，例如 ButtonWidget.disabled == true 时的背景色
          disabledColor: Color(0xffD9D9D9),
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff476bf3)),
        ),
        onGenerateRoute: (RouteSettings settings) {
          String name = settings.name!;
          return CupertinoPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              return routes[name]!(context);
            },
          );
        },
      ),
    );
  }
}
