library;

import 'package:flutter/material.dart';
import 'package:qm/utils/global_context.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _defaultDuration = Duration(milliseconds: 2500);

class Toast {
  static final double _height = 50.w;
  static OverlayEntry? _overlayEntry;
  static OverlayState? _overlayState;
  static final Curve _curve = Curves.ease;
  static AnimationController? _animationController;
  static final borderRadius = BorderRadius.circular(8.w);
  static final duration = const Duration(milliseconds: 300);
  static final reverseDuration = const Duration(milliseconds: 150);
  static final Color _bgColor = Colors.black.withValues(alpha: 0.6);

  static initial(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();

    if (_overlayEntry == null) {
      _overlayState = Overlay.of(context);
      _animationController = AnimationController(vsync: _overlayState!, duration: duration);
      _animationController!.forward();
    }
  }

  static close(OverlayEntry entry) {
    return () async {
      if (entry == _overlayEntry) {
        _animationController?.reverseDuration = reverseDuration;
        await _animationController?.reverse();
        _overlayEntry?.remove();
        _overlayEntry?.dispose();
        _overlayEntry = null;
      }
    };
  }

  static createOverEntry(
      {required double width, required Widget child, required FractionalOffset offset}) {
    _overlayEntry = OverlayEntry(
      opaque: false,
      maintainState: false,
      builder: (BuildContext context) {
        /// 屏幕可视区的大小
        final size = MediaQuery.sizeOf(context);
        if (width < 100.w) width = 100.w;
        if (width > 170.w) width = 170.w;

        debugPrint('${FractionalOffset(0.5, 0.6).dy * (size.height - _height)}');
        return Positioned(
          width: width,
          height: _height,
          left: (size.width - width) * offset.dx,
          top: (size.height - _height) * offset.dy,
          child: Material(
            type: MaterialType.transparency,
            child: FadeTransition(
              opacity: _animationController!.drive(CurveTween(curve: _curve)),
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints.expand(),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(6)),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  static show(
    String text, {
    Duration duration = _defaultDuration,
    FractionalOffset offset = const FractionalOffset(0.5, 0.25),
  }) {
    final width = text.length * 20.w;
    initial(GlobalVars.context);
    createOverEntry(
      width: width,
      offset: offset,
      child: Text(
        text,
        softWrap: false,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.white,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    _overlayState!.insert(_overlayEntry!);
    Future.delayed(duration, close(_overlayEntry!));
  }
}
