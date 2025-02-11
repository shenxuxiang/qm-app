import 'package:qmnj/utils/index.dart';
import 'package:flutter/material.dart';

button({required String text, required void Function() onPressed, bool isActive = false}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(RoundedRectangleBorder()),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: isActive ? Color(0xff476bf3) : Colors.black54,
      ),
    ),
  );
}

class HeaderTabs extends StatelessWidget {
  final int value;
  final double width;
  final double height;
  final Function(int value) onChanged;

  const HeaderTabs({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: PaintBG(activeKey: value),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              width: width / 2,
              height: height,
              child: button(
                text: '快捷登录',
                isActive: value == 0,
                onPressed: () {
                  hapticFeedback();
                  onChanged(0);
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              width: width / 2,
              height: height,
              child: button(
                text: '账号登录',
                isActive: value == 1,
                onPressed: () {
                  hapticFeedback();
                  onChanged(1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaintBG extends CustomPainter {
  final int activeKey;

  const PaintBG({required this.activeKey});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    double width = size.width;
    double height = size.height;

    Path path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(width / 2 - 5, 0)
      ..lineTo(width / 2 + 5, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(
      path1,
      Paint()
        ..color = activeKey == 0 ? Color(0xFFF2F2F2) : Color(0xFFE9E9E9)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    Path path2 = Path()
      ..moveTo(width / 2 - 5, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height)
      ..lineTo(width / 2 + 5, height)
      ..close();

    canvas.drawPath(
      path2,
      Paint()
        ..color = activeKey == 1 ? Color(0xFFF2F2F2) : Color(0xFFE9E9E9)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(PaintBG oldDelegate) {
    if (oldDelegate.activeKey == activeKey) {
      return true;
    } else {
      return false;
    }
  }
}
