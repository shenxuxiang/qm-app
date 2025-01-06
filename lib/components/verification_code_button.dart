import 'dart:async';
import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationCodeButton extends StatefulWidget {
  final String label;
  final Future<dynamic> Function() sendRequest;

  const VerificationCodeButton({super.key, this.label = '获取验证码', required this.sendRequest});

  @override
  State<VerificationCodeButton> createState() => _VerificationCodeButtonState();
}

class _VerificationCodeButtonState extends State<VerificationCodeButton> {
  Stream<int>? _stream;
  int? _countdown;

  /// 开始计时
  void startTiming() async {
    if (_stream != null) return;
    try {
      /// 发送验证码
      await widget.sendRequest();

      Toast.show('验证码已发送');
      setState(() => _countdown = 59);

      _stream = Stream.periodic(const Duration(seconds: 1), (int count) => count).take(60);
      _stream!.listen(
        (int count) {
          setState(() {
            _countdown = 59 - count - 1;
          });
        },
        onDone: () {
          setState(() {
            _stream = null;
            _countdown = null;
          });
        },
      );
    } catch (err) {
      debugPrint('error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.w,
      height: 24.w,
      child: ElevatedButton(
        onPressed: startTiming,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          maximumSize: WidgetStateProperty.all(Size(70.w, 24.w)),
          minimumSize: WidgetStateProperty.all(Size(70.w, 24.w)),
          backgroundColor: WidgetStateProperty.all(
            _countdown == null ? Color(0xff476bf3) : Color(0xFFb3b3b3),
          ),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          )),
        ),
        child: Text(
          _countdown == null ? widget.label : '$_countdown 秒',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
