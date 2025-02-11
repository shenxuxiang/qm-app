import 'package:qmnj/utils/index.dart';
import 'package:qmnj/entity/response_data.dart';

Future<ResponseData> queryVerificationCode(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/sms/send', data: query);
}

/// 获取服务主体
Future<ResponseData> querySystemOrganization(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/sysOrganization/tree', data: query);
}

/// 用户注册
Future<ResponseData> queryUserRegister(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/sysUser/register', data: query);
}

/// 手机号-验证码登录
Future<ResponseData> queryUserLoginPhoneCode(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/login/phoneCode', data: query);
}

/// 账号-密码登录
Future<ResponseData> queryUserLoginApp(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/login/app', data: query);
}

/// 获取用户信息
Future<ResponseData> queryUserInfo() async {
  return httpRequest.post('/v1.0/sysUser/info', data: {});
}

/// 推出登录
Future<ResponseData> queryUserLogout() async {
  return httpRequest.post('/v1.0/sysUser/logout', data: {});
}

/// 字典类型列表
Future<ResponseData> queryDictionaryTypeList() async {
  return httpRequest.post('/v1.0/sysDictType/list', data: {});
}

/// 生产环节列表
Future<ResponseData> queryProductLinkList() async {
  return httpRequest.post('/v1.0/sysDict/list', data: {'dictTypeCode': 'PRODUCT_LINK'});
}

/// 农作物列表
Future<ResponseData> queryCropsTypeList() async {
  return httpRequest.post('/v1.0/sysDict/list', data: {'dictTypeCode': 'WORK_SEASON'});
}

/// 作业类型列表
Future<ResponseData> queryWorkTypeList() async {
  return httpRequest.post('/v1.0/sysJobType/list', data: {});
}

/// 开始作业
Future<ResponseData> queryDriverWork(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/driverWork/startWork', data: query);
}

/// 结束作业
Future<ResponseData> queryEndWork(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/WorkOriginalTracePoint/add', data: query);
}

/// 获取 region
Future<ResponseData> queryRegionList(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/chinaProvince/region', data: query);
}

/// 获取作业列表
Future<ResponseData> queryDriveWorkList(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/driverWork/workInfoPage', data: query);
}

/// 获取作业详情
Future<ResponseData> queryDriveWorkDetail(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/driverWork/workInfoDetail', data: query);
}

/// 获取App更新记录列表
Future<ResponseData> queryAppVersions(Map<String, dynamic>? query) async {
  return httpRequest.post('/v1.0/appVersion/page', data: query);
}
