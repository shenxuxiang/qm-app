import 'dart:async';
import 'custom_title.dart';
import 'input_widget.dart';
import 'package:get/get.dart';
import 'package:qm/global_vars.dart';
import 'package:qm/models/main.dart';
import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
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
  String _phone = '';
  bool _checked = false;
  bool _disabled = true;
  String _verificationCode = '';

  @override
  void initState() {
    _phone = Get.find<Storage>().getItem('User-Phone') ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleChangePhone(String value) {
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
      final storage = Get.find<Storage>();
      final res = await api.queryUserLoginPhoneCode({'phone': _phone, 'code': _verificationCode});
      // 将用户 token 保存在本地
      await storage.setItem('User-Token', res.data['token']);
      // 获取用户信息
      final userInfo = (await api.queryUserInfo()).data;
      // 将用户信息保存在本地
      await storage.setItem('User-Info', userInfo);
      // 将用户登录的手机号保存在本地
      await storage.setItem('User-Phone', _phone);
      Get.find<MainModels>().setUserInfo(userInfo);

      /// 登录成功后，立即返回到 APP 首页
      Get.offAllNamed('/');
    } catch (error, stack) {
      debugPrint('error: $error');
      debugPrint('stack: $stack');
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
          autofillHints: [AutofillHints.oneTimeCode],
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
