import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/utils/index.dart';
import 'package:qmnj/global_vars.dart';
import 'package:flutter/services.dart';
import 'package:qmnj/routes.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await userLocation.init();
  await storage.init();

  /// 设置导航栏颜色为黑色、设置导航栏图标为浅色
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const QmApp());
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
      child: GetMaterialApp(
        title: 'QM-APP',
        initialRoute: '/',
        getPages: Routes.getPages,
        defaultTransition: Transition.cupertino,
        initialBinding: GlobalDependenceBinding(),
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            elevation: 4,
            centerTitle: true,
            backgroundColor: Color(0xff476bf3),
            iconTheme: IconThemeData(color: Colors.white, size: 22),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
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
        routingCallback: (Routing? routing) {
          debugPrint('context: ${Get.context}');
          debugPrint('args: ${routing?.args}');
          debugPrint('route: ${routing?.route}');
          debugPrint('isBack: ${routing?.isBack}');
          debugPrint('isDialog: ${routing?.isDialog}');
          debugPrint('isBottomSheet: ${routing?.isBottomSheet}');
          final isBottomSheet = routing?.isBottomSheet ?? false;
          final isDialog = routing?.isDialog ?? false;

          if (!isBottomSheet && !isDialog) GlobalVars.context = Get.context;
        },
        localizationsDelegates: [
          // 本地化的代理类，一般都是这三个
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // 美国英语
          const Locale('zh', 'CN'), // 中文简体
          // 其他Locales
        ],
      ),
    );
  }
}
