import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

typedef BottomSheetBuilder = Widget Function(
  BuildContext context, {
  Widget? child,
  required Future<void> Function() onClose,
});

class BottomSheet {
  static show({
    Widget? child,
    double? height,
    bool barrierDismissible = true,
    required BottomSheetBuilder builder,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 200),
  }) {
    Get.dialog(
      _BottomSheetWidget(
        barrierDismissible: barrierDismissible,
        reverseDuration: reverseDuration,
        onClose: () => Get.back(),
        duration: duration,
        builder: builder,
        height: height,
        child: child,
      ),
      useSafeArea: false,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
    );
  }
}

class _BottomSheetWidget extends StatefulWidget {
  final Widget? child;
  final double? height;
  final Duration duration;
  final VoidCallback onClose;
  final bool barrierDismissible;
  final Duration reverseDuration;
  final BottomSheetBuilder builder;

  const _BottomSheetWidget({
    super.key,
    this.child,
    this.height,
    required this.onClose,
    required this.builder,
    required this.duration,
    required this.reverseDuration,
    required this.barrierDismissible,
  });

  @override
  State<_BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<_BottomSheetWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  Future<void> handleClose() async {
    _animationController.reverseDuration = widget.reverseDuration;
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: widget.duration);
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
    Size size = MediaQuery.sizeOf(context);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          /// 遮罩层
          GestureDetector(
            onTap: () {
              if (widget.barrierDismissible) handleClose();
            },
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

          /// 内容部分
          Positioned(
            left: 0,
            bottom: 0,
            width: size.width,
            height: widget.height ?? size.height / 2,
            child: FadeTransition(
              opacity: _animation.drive(Tween(begin: 0.6, end: 1)),
              child: SlideTransition(
                position: _animation.drive(Tween(begin: Offset(0, 1), end: Offset.zero)),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.w),
                      topRight: Radius.circular(10.w),
                    ),
                  ),
                  child: Builder(
                    builder: (BuildContext context) {
                      return widget.builder(context, child: widget.child, onClose: handleClose);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
