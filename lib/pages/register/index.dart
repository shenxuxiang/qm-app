import 'components/input.dart';
import 'package:qm/common/base.dart';
import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:qm/api/main.dart' as api;
import 'components/service_principal.dart';
import 'package:qm/entity/organization.dart';
import 'package:qm/components/qm_checkbox.dart';
import 'package:qm/components/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qm/components/verification_code_button.dart';

class RegisterPage extends BasePage {
  const RegisterPage({super.key, super.title});

  @override
  BasePageState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends BasePageState<RegisterPage> {
  String _phone = '';
  String _passwd = '';
  String _idNumber = '';
  String _realName = '';
  bool _checked = false;
  String _verificationCode = '';
  Organization? _servicePrincipal;

  _RegisterPageState({super.author = false});

  @override
  void initState() {
    super.initState();
  }

  /// 返回上一页
  handleGoBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 修改手机号
  void handleChangePhone(String value) {
    setState(() {
      _phone = value;
    });
  }

  /// 发送验证码
  Future<dynamic> handleSendVerificationCode() async {
    if (_phone.isEmpty) {
      Toast.show('请输入手机号码');
      throw Exception('手机号不能为空');
    }

    return api.queryVerificationCode({'type': '2', 'phone': _phone});
  }

  /// 用户注册
  handleSubmit() async {
    if (!_checked) {
      Toast.show('请同意并勾选用户协议');
      return;
    }

    if (_verificationCode.isEmpty) {
      Toast.show('请输入验证码');
      return;
    }

    if (_passwd.isEmpty) {
      Toast.show('请输入密码');
      return;
    } else if (!GlobalVars.userPasswordPattern.hasMatch(_passwd)) {
      Toast.show('密码格式不正确');
      return;
    }

    if (_realName.isEmpty) {
      Toast.show('请输入姓名');
      return;
    }

    if (_idNumber.isEmpty) {
      Toast.show('请输入身份证号码');
      return;
    } else if (!RegExp(r'\d{18}').hasMatch(_idNumber)) {
      Toast.show('请输入正确的身份证号码');
      return;
    }

    if (_servicePrincipal == null) {
      Toast.show('请输入选择服务主体');
      return;
    }
    try {
      await api.queryUserRegister({
        'phone': _phone,
        'password': _passwd,
        'realName': _realName,
        'idNumber': _idNumber,
        'code': _verificationCode,
        'organizationId': _servicePrincipal!.organizationId,
      });
      if (GlobalVars.context.mounted) {
        Navigator.of(GlobalVars.context).pop(_phone);
      }
    } on DioException catch (err) {
      debugPrint('error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/register_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              centerTitle: true,
              title: Text(widget.title),
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.white, size: 22.sp),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.sp),
              leading: GestureDetector(
                onTap: () => handleGoBack(context),
                child: Icon(QmIcons.back),
              ),
            ),
            SizedBox(height: 20.w),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: 320.w,
                  // height: 500.w,
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Input(
                          onChanged: (String value) => setState(() => _phone = value),
                          keyboardType: TextInputType.number,
                          placeholder: '请输入手机号',
                          title: '手机号码',
                          value: _phone,
                        ),
                        Input(
                          onChanged: (String value) => setState(() => _passwd = value),
                          keyboardType: TextInputType.text,
                          placeholder: '请输入密码（同时包含数字字母特殊符号）',
                          obscureText: true,
                          title: '密码',
                          value: _passwd,
                        ),
                        Input(
                          onChanged: (String value) => setState(() => _realName = value),
                          keyboardType: TextInputType.text,
                          placeholder: '请输入姓名',
                          value: _realName,
                          title: '姓名',
                        ),
                        Input(
                          onChanged: (String value) => setState(() => _idNumber = value),
                          keyboardType: TextInputType.number,
                          placeholder: '请输入身份证号码',
                          value: _idNumber,
                          title: '身份证',
                        ),
                        ServicePrincipal(
                          title: '服务主体',
                          value: _servicePrincipal,
                          onChanged: (Organization value) =>
                              setState(() => _servicePrincipal = value),
                        ),
                        Input(
                          title: '验证码',
                          value: _verificationCode,
                          placeholder: '请输入验证码',
                          keyboardType: TextInputType.number,
                          onChanged: (String value) => setState(() => _verificationCode = value),
                          suffix: VerificationCodeButton(sendRequest: handleSendVerificationCode),
                        ),
                        SizedBox(height: 26.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                    style: TextStyle(color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.w),
                        ButtonWidget(
                          onPressed: handleSubmit,
                          text: '注册',
                        ),
                        SizedBox(height: 10.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
          ],
        ),
      ),
    );
  }
}
