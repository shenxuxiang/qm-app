import 'package:get/get.dart';
import 'package:qmnj/entity/work_type.dart';
import 'package:qmnj/entity/crops_type.dart';

class MainModels extends GetxController {
  /// 用户信息
  final userInfo = <String, dynamic>{}.obs;

  void setUserInfo(Map<String, dynamic>? value) {
    userInfo.value = value ?? {};
  }

  /// 服务主体
  final systemOrganization = <dynamic>[].obs;

  void setSystemOrganization(List<dynamic> newValue) {
    systemOrganization.value = newValue;
  }

  /// 农作物类型列表
  final cropsTypeList = <CropsType>[].obs;

  void setCropsTypeList(List<CropsType> newValue) {
    cropsTypeList.value = newValue;
  }

  /// 作业物类型列表
  final workTypeList = <WorkType>[].obs;

  void setWorkTypeList(List<WorkType> newValue) {
    workTypeList.value = newValue;
  }

  /// 省市区
  final regionList = <dynamic>[].obs;

  void setRegionList(List<dynamic> newValue) {
    regionList.value = newValue;
  }
}
