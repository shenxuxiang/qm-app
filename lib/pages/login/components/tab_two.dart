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

class TabTwo extends StatefulWidget {
  const TabTwo({super.key});

  @override
  State<TabTwo> createState() => _TabTwoState();
}

class _TabTwoState extends State<TabTwo> {
  String _passwd = '';
  String _account = '';
  bool _checked = false;
  bool _disabled = true;

  @override
  void initState() {
    super.initState();
  }

  /// 输入账户
  void handleChangeAccount(String value) {
    setState(() {
      _account = value;
      _disabled = !(value.isNotEmpty && _passwd.length >= 6);
    });
  }

  /// 输入密码
  void handleChangePasswd(String value) {
    setState(() {
      _passwd = value;
      _disabled = !(_account.isNotEmpty && value.length >= 6);
    });
  }

  /// 登录
  void handleLogin() async {
    if (_disabled) return;
    if (!_checked) {
      Toast.show('请勾选用户协议');
      return;
    }

    if (!GlobalVars.userPasswordPattern.hasMatch(_passwd)) {
      Toast.show('密码格式不正确');
      return;
    }

    try {
      final res = await api.queryUserLoginApp({'username': _account, 'password': _passwd});
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 20.w),
        InputWidget(
          value: _account,
          placeholder: '请输入用户账号',
          onChanged: handleChangeAccount,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 20.w),
        InputWidget(
          maxLength: 18,
          value: _passwd,
          obscureText: true,
          placeholder: '请输入用户密码',
          onChanged: handleChangePasswd,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 40.w),
        ButtonWidget(
          text: '登录',
          height: 40.w,
          disabled: _disabled,
          onPressed: handleLogin,
        ),
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
        CustomTitle(title: '注册新账户', height: 30.w),
        SizedBox(height: 20.w),
        ButtonWidget(
          ghost: true,
          text: '注册',
          height: 40.w,
          type: 'default',
          onPressed: () async {
            final result = await Navigator.of(context).pushNamed('/register');
            if (result != null) {
              setState(() => _account = result as String);
            }
          },
        ),
      ],
    );
  }
}
