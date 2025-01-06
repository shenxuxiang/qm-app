import 'package:qm/utils/index.dart';
import 'package:qm/entity/response_data.dart';

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
