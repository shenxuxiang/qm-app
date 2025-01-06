import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTitle extends StatelessWidget {
  final String title;
  final double width;
  final double height;

  const CustomTitle(
      {super.key, required this.title, this.height = 40, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DrawFont(title),
      ),
    );
  }
}

class _DrawFont extends CustomPainter {
  final String title;

  const _DrawFont(this.title);

  @override
  void paint(Canvas canvas, Size size) {
    var textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: title,
        style: TextStyle(fontSize: 14.sp, color: Colors.black45),
      ),
      textAlign: TextAlign.center,
    );

    /// 布局，并计算出文本的宽度和高度
    textPainter.layout();
    double width = textPainter.width;
    double height = textPainter.height;

    /// 绘制文本
    textPainter.paint(canvas, Offset((size.width - width) / 2, (size.height - height) / 2));

    /// 将头和文字的左右边距
    double padding = 5.w;

    /// 箭头的长度
    double distance = 30.w;

    /// 绘制左边箭头路径
    Path leftArrow = Path()
      ..moveTo((size.width - width) / 2 - (padding + distance), size.height / 2)
      ..lineTo((size.width - width) / 2 - padding, size.height / 2 + 0.8)
      ..lineTo((size.width - width) / 2 - padding, size.height / 2 - 0.8)
      ..close();

    /// 绘制右边箭头路径
    Path rightArrow = Path()
      ..moveTo((size.width + width) / 2 + (padding + distance), size.height / 2)
      ..lineTo((size.width + width) / 2 + padding, size.height / 2 + 0.8)
      ..lineTo((size.width + width) / 2 + padding, size.height / 2 - 0.8)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black26
      ..isAntiAlias = true;

    canvas.drawPath(leftArrow, paint);
    canvas.drawPath(rightArrow, paint);
  }

  @override
  bool shouldRepaint(_DrawFont oldDelegate) {
    if (oldDelegate.title != title) {
      return true;
    } else {
      return false;
    }
  }
}
