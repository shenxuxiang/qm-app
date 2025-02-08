library;

/// 全局用户提示框
///
/// 点击遮罩层会关闭 Toast；
/// 连续多次触发 Toast.show() 并不会连续弹出多个 Toast；
/// 界面始终只会展示一个 Toast 提示框，如果当前 Toast 还未关闭此时又调用 Toast.show()，
/// 界面此时会更新 Toast 文案提示，并不会弹出一个新的 Toast 弹框。
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Quaternion;

class Toast {
  static final _text = ''.obs;
  static bool _isClosed = true;

  static close() {
    if (_isClosed) return;
    _isClosed = true;
    Get.back();
  }

  static show(
    String text, {
    Duration duration = const Duration(milliseconds: 2500),
    FractionalOffset offset = const FractionalOffset(0.5, 0.35),
  }) {
    _text.value = text;
    if (_isClosed) {
      _isClosed = false;
      Get.dialog(
        Obx(
          () => _ToastWidget(
            offset: offset,
            text: _text.value,
            duration: duration,
            onClosed: Toast.close,
          ),
        ),
        useSafeArea: false,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: Duration.zero,
      );
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String text;
  final Duration duration;
  final VoidCallback onClosed;
  final FractionalOffset offset;

  const _ToastWidget({
    super.key,
    required this.text,
    required this.offset,
    required this.duration,
    required this.onClosed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  Timer? _timer;
  final double _height = 50.w;
  final Curve _curve = Curves.ease;
  AnimationController? _animationController;

  /// 控制圆角大小
  final borderRadius = BorderRadius.circular(8.w);

  /// 控制背景的不透明度
  final Color _bgColor = Colors.black.withValues(alpha: 0.6);
  final Duration duration = const Duration(milliseconds: 200);
  final Duration reverseDuration = const Duration(milliseconds: 150);

  /// 立即关闭
  void immediatelyClose() async {
    _timer?.cancel();
    _animationController!.reverseDuration = reverseDuration;
    await _animationController!.reverse();

    /// 关闭 Toast；
    widget.onClosed();
  }

  /// 即将关闭 (在 duration 之后关闭)
  void willClose() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.duration, (Timer time) {
      immediatelyClose();
    });
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: duration);
    _animationController!.forward();
    super.initState();

    willClose();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _timer?.cancel();
    // widget.onClosed();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    double width = widget.text.length * 20.w;

    /// 屏幕可视区的大小
    final size = MediaQuery.sizeOf(context);
    double height = _height;
    if (width < 100.w) {
      width = 100.w;
    } else if (width > 200.w) {
      width = 200.w;
      height = 1.5 * _height;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: immediatelyClose,
          child: Container(color: Color(0x22000000)),
        ),
        Positioned(
          width: width,
          height: height,
          left: (size.width - width) * widget.offset.dx,
          top: (size.height - height) * widget.offset.dy,
          child: Material(
            type: MaterialType.transparency,
            child: MatrixTransition(
              animation: _animationController!.drive(CurveTween(curve: _curve)),
              onTransform: (double value) {
                return Matrix4Tween(
                  begin: _animationController!.status == AnimationStatus.forward
                      ? Matrix4.compose(
                          Vector3(0, -50, 0),
                          Quaternion.identity(),
                          Vector3(0.7, 0.7, 1),
                        )
                      : Matrix4.identity(),
                  end: Matrix4.identity(),
                ).lerp(value);
              },
              child: FadeTransition(
                opacity: _animationController!.drive(CurveTween(curve: _curve)),
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints.expand(),
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.text,
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 14.w,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
