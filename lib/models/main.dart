import 'package:flutter/material.dart';
import 'package:qm/utils/index.dart';

class MainModels extends ChangeNotifier {
  MainModels(BuildContext context) {
    /// 用户在登录时已经在用户信息保存在了本地。
    Storage.getItem<Map<String, dynamic>>('User-Info').then((data) {
      _userInfo = data!;
      notifyListeners();
    });
  }

  /// 用户信息
  ///
  /// 全局只有这一个地方可以获取用户信息。
  Map<String, dynamic>? _userInfo;

  Map<String, dynamic>? get userInfo => _userInfo;

  void setUserInfo(Map<String, dynamic>? value) {
    _userInfo = value;
    notifyListeners();
  }

  /// 服务主体
  List<dynamic> _systemOrganization = [];

  List<dynamic> get systemOrganization => _systemOrganization;

  void setSystemOrganization(List<dynamic> newValue) {
    _systemOrganization = newValue;
    notifyListeners();
  }
}
