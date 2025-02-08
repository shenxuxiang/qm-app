import 'package:get/get.dart';
import 'package:qm/models/main.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:qm/pages/home.dart' show HomePage;
import 'package:qm/models/connect_device_models.dart';
import 'package:qm/pages/login/index.dart' show LoginPage;
import 'package:qm/pages/work_type.dart' show WorkTypePage;
import 'package:qm/pages/work_detail.dart' show WorkDetail;
import 'package:qm/pages/register/index.dart' show RegisterPage;
import 'package:qm/pages/update_records.dart' show UpdateRecords;
import 'package:qm/pages/connect_device/index.dart' show ConnectDevice;

/// 全局依赖注入
class GlobalDependenceBinding implements Bindings {
  @override
  void dependencies() {
    final mainModels = Get.put<MainModels>(MainModels(), permanent: true);
    final storage = Get.put<utils.Storage>(utils.storage, permanent: true);
    mainModels.setUserInfo(storage.getItem('User-Info'));
  }
}

class Routes {
  static final List<GetPage> getPages = [
    GetPage(
      name: '/',
      page: () => const HomePage(title: '阡陌农服'),
      binding: BindingsBuilder(() {
        Get.put<ConnectDeviceModels>(ConnectDeviceModels());
      }),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginPage(title: '登录'),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(title: '注册'),
    ),
    GetPage(
      name: '/work_type',
      page: () => const WorkTypePage(title: '作业类型'),
      binding: BindingsBuilder(() {
        Get.put<ConnectDeviceModels>(ConnectDeviceModels());
      }),
    ),
    GetPage(
      name: '/connect_device',
      page: () => const ConnectDevice(title: '连接设备'),
      binding: BindingsBuilder(() {
        Get.put<ConnectDeviceModels>(ConnectDeviceModels());
      }),
    ),
    GetPage(
      name: '/update_records',
      page: () => const UpdateRecords(title: '更新记录'),
    ),
    GetPage(
      name: '/work_detail',
      page: () => const WorkDetail(title: '作业详情'),
    ),
  ];
}
