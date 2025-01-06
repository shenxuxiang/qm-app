import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StickyPositioned extends MultiChildRenderObjectWidget {
  final Widget body;
  final Widget header;

  StickyPositioned({super.key, required this.body, required this.header})
      : super(children: [body, header]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final scrollPosition = Scrollable.of(context).position;
    return _RenderStickyPositioned(scrollPosition: scrollPosition);
  }
//
// @override
// void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
//
//   super.updateRenderObject(context, renderObject);
// }
}

class _RenderStickyPositioned extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  final ScrollPosition scrollPosition;

  _RenderStickyPositioned({required this.scrollPosition});

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
    super.setupParentData(child);
  }

  @override
  void attach(PipelineOwner owner) {
    scrollPosition.addListener(markNeedsLayout);
    super.attach(owner);
  }

  @override
  void detach() {
    scrollPosition.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  bool get isRepaintBoundary => true;

  double computeOverflowExtent() {
    final scrollBox = scrollPosition.context.notificationContext?.findRenderObject();

    if (scrollBox?.attached ?? false) {
      try {
        return localToGlobal(Offset.zero, ancestor: scrollBox).dy;
      } catch (err) {}
    }
    return 0;
  }

  @override
  void performLayout() {
    final body = firstChild!;
    final header = lastChild!;

    body.layout(constraints.loosen(), parentUsesSize: true);
    header.layout(constraints.loosen(), parentUsesSize: true);

    double bodyW = body.size.width;
    double bodyH = body.size.height;
    double headerW = header.size.width;
    double headerH = header.size.height;

    size = constraints.constrain(Size(
      constraints.maxWidth == double.infinity ? math.max(bodyW, headerW) : double.infinity,
      bodyH + headerH,
    ));

    MultiChildLayoutParentData bodyParentData = body.parentData as MultiChildLayoutParentData;
    bodyParentData.offset = Offset(0, headerH);

    double overflowExtent = computeOverflowExtent();
    double maxExtent = size.height - headerH;

    MultiChildLayoutParentData headerParentData = header.parentData as MultiChildLayoutParentData;
    if (overflowExtent >= 0) {
      headerParentData.offset = Offset(0, 0);
    } else {
      headerParentData.offset = Offset(0, math.min(overflowExtent.abs(), maxExtent));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return firstChild!.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return firstChild!.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return lastChild!.getMinIntrinsicHeight(width) + firstChild!.getMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return (lastChild!.getMaxIntrinsicHeight(width) + firstChild!.getMaxIntrinsicHeight(width));
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }
}
