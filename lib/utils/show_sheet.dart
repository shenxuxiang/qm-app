import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef SheetBuilder = Widget Function(
  BuildContext context, {
  Widget? child,
  required VoidCallback onClosed,
});

showSheet({
  Widget? child,
  double? height,
  bool isDismissible = true,
  required BuildContext context,
  required SheetBuilder builder,
  Duration animationDuration = const Duration(milliseconds: 200),
}) {
  late final OverlayEntry overlayEntry;
  final size = MediaQuery.sizeOf(context);
  final overlayStrate = Overlay.of(context);
  final animationController = AnimationController(
    vsync: overlayStrate,
    duration: animationDuration,
  );
  final animation = CurveTween(curve: Curves.ease).animate(animationController);

  /// 关闭 sheet
  handleClose() async {
    animationController.reverseDuration = const Duration(milliseconds: 150);
    await animationController.reverse();
    overlayEntry.remove();
    overlayEntry.dispose();
  }

  overlayEntry = OverlayEntry(
    maintainState: false,
    opaque: false,
    builder: (BuildContext ctx) {
      return Positioned(
        top: 0,
        left: 0,
        width: size.width,
        height: size.height,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              /// 遮罩层
              GestureDetector(
                onTap: () => {if (isDismissible) handleClose()},
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? _) {
                    return Opacity(
                      opacity: animation.value,
                      child: Container(
                        constraints: BoxConstraints.expand(),
                        color: Color(0xaa000000),
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
                height: height ?? size.height / 2,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget? child) {
                    final position = Offset.lerp(Offset(0, 1), Offset.zero, animation.value)!;
                    return FractionalTranslation(translation: position, child: child!);
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.w),
                        topRight: Radius.circular(10.w),
                      ),
                      color: Colors.white,
                    ),
                    child: Builder(
                      builder: (BuildContext context) {
                        return builder(context, child: child, onClosed: handleClose);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  animationController.forward();
  overlayStrate.insert(overlayEntry);
}
