import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class QmCheckbox extends LeafRenderObjectWidget {
  final bool value;
  final double size;
  final Color? color;
  final BoxShape shape;
  final double borderWidth;
  final double borderRadius;
  final bool enableHapticFeedback;
  final void Function(bool value) onChanged;

  const QmCheckbox({
    super.key,
    this.color,
    this.size = 25,
    required this.value,
    this.borderWidth = 1,
    this.borderRadius = 4,
    required this.onChanged,
    this.shape = BoxShape.rectangle,
    this.enableHapticFeedback = false,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return RenderQmCheckbox(
      width: size,
      height: size,
      value: value,
      onChanged: onChanged,
      borderWidth: borderWidth,
      color: color ?? themeData.primaryColor,
      enableHapticFeedback: enableHapticFeedback,
      borderRadius: shape == BoxShape.circle ? size / 2 : borderRadius,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderQmCheckbox renderObject) {
    super.updateRenderObject(context, renderObject);
    ThemeData themeData = Theme.of(context);
    if (renderObject.value != value) {
      renderObject.value = value;
      renderObject.play();
    }

    renderObject
      ..width = size
      ..height = size
      ..onChanged = onChanged
      ..borderWidth = borderWidth
      ..color = color ?? themeData.primaryColor
      ..enableHapticFeedback = enableHapticFeedback
      ..borderRadius = shape == BoxShape.circle ? size / 2 : borderRadius;
  }
}

class RenderQmCheckbox extends RenderBox {
  bool value;
  Color color;
  double width;
  double height;
  int? _pointerId;
  double borderWidth;
  double borderRadius;
  bool enableHapticFeedback;
  void Function(bool value) onChanged;

  double _progress = 0;
  Duration? _lastTimeStamp;
  AnimationStatus _animationStatus;

  RenderQmCheckbox({
    required this.value,
    required this.color,
    required this.width,
    required this.height,
    required this.onChanged,
    required this.borderWidth,
    required this.borderRadius,
    required this.enableHapticFeedback,
  })  : _animationStatus = value ? AnimationStatus.completed : AnimationStatus.dismissed,
        _progress = value ? 1 : 0;

  @override
  hitTestSelf(Offset position) => true;

  @override
  handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event.down) {
      _pointerId = event.pointer;
      // 防止手指滑动操作触发 checbox 的 onChanged 事件
      if (event is PointerMoveEvent && (event.delta.dx != 0 || event.delta.dy != 0)) {
        _pointerId = null;
      }
    } else if (_pointerId == event.pointer) {
      onChanged(!value);
    }
  }

  play() {
    _animationStatus = value ? AnimationStatus.forward : AnimationStatus.reverse;
    if (enableHapticFeedback) hapticFeedback();
    _lastTimeStamp = null;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(constraints.isTight ? constraints.biggest : Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Rect rect = offset & size;
    if (_progress <= 0.4) {
      drawBG(context.canvas, rect, _progress / 0.4);
    } else {
      drawBG(context.canvas, rect, 1);
      drawTick(context.canvas, rect, (_progress - 0.4) / 0.6);
    }

    if (_animationStatus == AnimationStatus.forward ||
        _animationStatus == AnimationStatus.reverse) {
      SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    }
  }

  postFrameCallback(Duration timeStamp) {
    if (_lastTimeStamp == null) {
      _lastTimeStamp = timeStamp;
      markNeedsPaint();
    } else {
      double delta = (timeStamp - _lastTimeStamp!).inMilliseconds / 200;
      if (_animationStatus == AnimationStatus.forward) {
        _progress += delta;
      } else {
        _progress -= delta;
      }
      _progress = _progress.clamp(0, 1);

      if (_progress >= 1) {
        _animationStatus = AnimationStatus.completed;
      } else if (_progress <= 0) {
        _animationStatus = AnimationStatus.dismissed;
      }
      _lastTimeStamp = timeStamp;
      markNeedsPaint();
    }
  }

  drawBG(Canvas canvas, Rect rect, double progress) {
    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rect.left + borderWidth / 2,
        rect.top + borderWidth / 2,
        rect.right - borderWidth / 2,
        rect.bottom - borderWidth / 2,
      ),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(
      rRect,
      Paint()
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.fill
        ..color = Color.lerp(Colors.white, color, progress)!,
    );
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = color
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  drawTick(Canvas canvas, Rect rect, double progress) {
    /// 绘制"勾"
    // "勾"的起始点
    final firstPoint = Offset(rect.left + rect.width / 7, rect.top + rect.height / 2);
    // "勾"的中间拐点位置
    final secondPoint = Offset(rect.left + rect.width / 2.5, rect.bottom - rect.height / 4);
    // "勾"的第三个点的位置
    final lastPoint = Offset(rect.right - rect.width / 5.5, rect.top + rect.height / 3.5);

    Paint paint = Paint()
      ..strokeWidth = rect.width / 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    Path path;
    if (progress <= 0.5) {
      Offset offset = Offset.lerp(firstPoint, secondPoint, progress / 0.5)!;
      path = Path()
        ..moveTo(firstPoint.dx, firstPoint.dy)
        ..lineTo(offset.dx, offset.dy);
    } else {
      Offset offset = Offset.lerp(secondPoint, lastPoint, (progress - 0.5) / 0.5)!;
      path = Path()
        ..moveTo(firstPoint.dx, firstPoint.dy)
        ..lineTo(secondPoint.dx, secondPoint.dy)
        ..lineTo(offset.dx, offset.dy);
    }

    canvas.drawPath(path, paint);
  }
}
