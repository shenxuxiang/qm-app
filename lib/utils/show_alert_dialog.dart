import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/components/button_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Quaternion;

Future<bool?> showAlertDialog({
  Widget? content,
  required String title,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  String cancelText = '取消',
  String confirmText = '确认',
}) async {
  return Get.dialog(
    _AlertDialogWidget(
      title: title,
      content: content,
      onCancel: onCancel,
      onConfirm: onConfirm,
      cancelText: cancelText,
      confirmText: confirmText,
    ),
    useSafeArea: false,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
  );
}

class _AlertDialogWidget extends StatefulWidget {
  final String title;
  final Widget? content;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const _AlertDialogWidget({
    super.key,
    this.content,
    this.onCancel,
    this.onConfirm,
    required this.title,
    this.cancelText = '取消',
    this.confirmText = '确认',
  });

  @override
  State<_AlertDialogWidget> createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<_AlertDialogWidget>
    with SingleTickerProviderStateMixin {
  final double _width = 300.w;
  final double _verticalPadding = 10.w;
  final double _horizontalPadding = 16.w;
  late final Animation<double> _animation;
  late final AnimationController _animationController;
  final Duration reverseDuration = Duration(milliseconds: 200);

  handleClose() async {
    _animationController.reverseDuration = reverseDuration;
    await _animationController.reverse();
    Get.back();
  }

  handleCancel() async {
    _animationController.reverseDuration = reverseDuration;
    await _animationController.reverse();
    Get.back(result: false);
    if (widget.onCancel != null) widget.onCancel!();
  }

  handleConfirm() async {
    _animationController.reverseDuration = reverseDuration;
    await _animationController.reverse();
    Get.back(result: true);
    if (widget.onConfirm != null) widget.onConfirm!();
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animation = CurvedAnimation(parent: _animationController, curve: Curves.ease);

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: FractionalOffset(0.5, 0.45),
        children: [
          /// 遮罩层
          GestureDetector(
            onTap: handleClose,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? _) {
                return Opacity(
                  opacity: _animation.value,
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    color: Color(0xAA000000),
                  ),
                );
              },
            ),
          ),
          Positioned(
            width: _width,
            child: MatrixTransition(
              alignment: Alignment.topCenter,
              animation: _animation,
              onTransform: (double value) {
                return Matrix4Tween(
                  begin: _animation.status == AnimationStatus.forward
                      ? Matrix4.compose(
                          Vector3(0, -80, 0),
                          Quaternion.identity(),
                          Vector3(0.7, 0.7, 1),
                        )
                      : Matrix4.identity(),
                  end: Matrix4.identity(),
                ).lerp(value);
              },
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.w),
                    boxShadow: [
                      BoxShadow(color: Color(0x55000000), offset: Offset(5, 5), blurRadius: 10)
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: _verticalPadding,
                    horizontal: _horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            height: 2,
                            fontSize: 16.w,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.w, bottom: 20.w),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 14.w,
                            color: Colors.black87,
                          ),
                          child: widget.content == null ? SizedBox() : widget.content!,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonWidget(
                            ghost: true,
                            type: 'default',
                            onPressed: handleCancel,
                            text: widget.cancelText,
                            width: (_width - _horizontalPadding * 2.5) * 0.5,
                          ),
                          ButtonWidget(
                            onPressed: handleConfirm,
                            text: widget.confirmText,
                            width: (_width - _horizontalPadding * 2.5) * 0.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
