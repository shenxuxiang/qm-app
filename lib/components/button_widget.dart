import 'package:qmnj/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonWidget extends StatelessWidget {
  final bool enableHapticFeedback;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final bool disabled;
  final Widget? child;
  final String? text;
  final String type;
  final bool ghost;

  ButtonWidget({
    super.key,
    this.text,
    this.child,
    this.width,
    this.height,
    this.ghost = false,
    this.type = 'primary',
    this.disabled = false,
    required this.onPressed,
    this.enableHapticFeedback = false,
  }) : assert(() {
          if (text != null && child != null) {
            return false;
          } else {
            return true;
          }
        }());

  void onTap() {
    if (disabled) return;
    if (enableHapticFeedback) hapticFeedback();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    ButtonThemeData buttonThemeData = ButtonTheme.of(context);

    if (ghost) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 40.w,
        child: OutlinedButton(
          onPressed: onTap,
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            shape: WidgetStateProperty.all(buttonThemeData.shape as OutlinedBorder),
            overlayColor: disabled ? WidgetStateProperty.all(Colors.transparent) : null,
            side: WidgetStateProperty.all(BorderSide(
              color: disabled
                  ? themeData.disabledColor
                  : type == 'default'
                      ? buttonThemeData.colorScheme!.secondary
                      : themeData.primaryColor,
            )),
          ),
          child: child ??
              Text(
                text!,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: disabled
                      ? themeData.disabledColor
                      : type == 'default'
                          ? Colors.black54
                          : themeData.primaryColor,
                ),
              ),
        ),
      );
    } else {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 40.w,
        child: ElevatedButton(
          onPressed: onTap,
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            shape: WidgetStateProperty.all(buttonThemeData.shape as OutlinedBorder),
            overlayColor: disabled ? WidgetStateProperty.all(Colors.transparent) : null,
            backgroundColor: WidgetStateProperty.all(
              disabled ? themeData.disabledColor : themeData.primaryColor,
            ),
          ),
          child: child ??
              Text(
                text!,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: disabled ? Colors.black12 : Colors.white,
                ),
              ),
        ),
      );
    }
  }
}
