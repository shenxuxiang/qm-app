import 'custom_title.dart';
import 'input_widget.dart';
import 'package:qm/models/main.dart';
import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qm/api/main.dart' as api;
import 'package:qm/components/qm_checkbox.dart';
import 'package:qm/components/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qm/components/verification_code_button.dart';

class TabOne extends StatefulWidget {
  const TabOne({super.key});

  @override
  State<TabOne> createState() => _TabOneState();
}

class _TabOneState extends State<TabOne> {
  int? _countdown;
  String _phone = '';
  Stream<int>? _timer;
  bool _checked = false;
  bool _disabled = true;
  String _verificationCode = '';

  @override
  void initState() {
    super.initState();
  }

  void handleChangePhone(String value) {
    debugPrint('${GlobalVars.phonePattern}, ${GlobalVars.phonePattern.hasMatch(value)}');
    setState(() {
      _phone = value;
      _disabled = !(GlobalVars.phonePattern.hasMatch(value) && _verificationCode.length >= 6);
    });
  }

  void handleChangeVerificationCode(String code) {
    setState(() {
      _verificationCode = code;
      _disabled = !(GlobalVars.phonePattern.hasMatch(_phone) && code.length >= 6);
    });
  }

  /// 登录
  void handleLogin() async {
    if (_disabled) return;
    if (!_checked) {
      Toast.show('请勾选用户协议');
      return;
    }

    try {
      final res = await api.queryUserLoginPhoneCode({'phone': _phone, 'code': _verificationCode});
      // 将用户 token 保存在本地
      await Storage.setItem('User-Token', res.data['token']);
      // 获取用户信息
      final userInfo = (await api.queryUserInfo()).data;
      // 将用户信息保存在本地
      await Storage.setItem('User-Info', userInfo);

      if (GlobalVars.context.mounted) {
        GlobalVars.context.read<MainModels>().setUserInfo(userInfo);

        /// 登录成功后，立即返回到 APP 首页
        Navigator.of(GlobalVars.context).pushReplacementNamed('/');
      }
    } on DioException catch (err) {
      debugPrint('error: $err');
    }
  }

  /// 发送验证码
  Future<dynamic> handleSendVerificationCode() async {
    if (_phone.isEmpty) {
      Toast.show('请输入手机号码');
      throw Exception('手机号不能为空');
    }

    return api.queryVerificationCode({'type': '1', 'phone': _phone});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 20.w),
        InputWidget(
          value: _phone,
          placeholder: '请输入用户手机号',
          onChanged: handleChangePhone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 20.w),
        InputWidget(
          maxLength: 6,
          value: _verificationCode,
          placeholder: '请输入验证码',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onChanged: handleChangeVerificationCode,
          // 获取验证码按钮
          suffix: VerificationCodeButton(sendRequest: handleSendVerificationCode),
        ),
        SizedBox(height: 40.w),
        ButtonWidget(text: '登录', onPressed: handleLogin, height: 40.w, disabled: _disabled),
        SizedBox(height: 10.w),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            QmCheckbox(
              size: 16.w,
              value: _checked,
              borderRadius: 2.w,
              enableHapticFeedback: true,
              onChanged: (bool value) => setState(() => _checked = value),
            ),
            SizedBox(width: 6.w),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: '登录代表您已同意'),
                  TextSpan(
                    text: '《用户协议》',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(text: '和'),
                  TextSpan(
                    text: '《隐私协议》',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
            ),
          ],
        ),
        SizedBox(height: 50.w),
        CustomTitle(title: '其他登录方式', height: 30.w),
        SizedBox(height: 20.w),
        ButtonWidget(
          ghost: true,
          height: 40.w,
          type: 'default',
          text: '手机号一键登录',
          onPressed: handleLogin,
        ),
      ],
    );
  }
}
