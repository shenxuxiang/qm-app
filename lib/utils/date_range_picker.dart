import 'dart:core';
import 'toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Quaternion;

class DateRangePicker {
  static bool _isClosed = true;

  static Future<PickerDateRange?> show({PickerDateRange? value}) async {
    if (_isClosed) {
      _isClosed = false;
      PickerDateRange? result;
      await Get.dialog(
        _DateRangePicker(
          value: value,
          onClosed: () {
            if (_isClosed) return;
            Get.back();
            _isClosed = true;
          },
          onCancel: () {
            Get.back();
            _isClosed = true;
          },
          onConfirm: (PickerDateRange value) {
            result = value;
            Get.back();
            _isClosed = true;
          },
        ),
        useSafeArea: false,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: Duration.zero,
      );
      return result;
    }
    return null;
  }
}

class _DateRangePicker extends StatefulWidget {
  final VoidCallback onClosed;
  final VoidCallback onCancel;
  final PickerDateRange? value;
  final void Function(PickerDateRange value) onConfirm;

  const _DateRangePicker({
    super.key,
    this.value,
    required this.onClosed,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<_DateRangePicker> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.ease);
    _animationController.forward();
    super.initState();
  }

  void handleConfirm(dynamic value) async {
    if (value.startDate == null) {
      Toast.show('请选择开始时间');
      return;
    } else if (value.endDate == null) {
      Toast.show('请选择结束时间');
      return;
    }

    _animationController.reverseDuration = Duration(milliseconds: 200);
    await _animationController.reverse();
    widget.onConfirm(value as PickerDateRange);
  }

  void handleCancel() async {
    _animationController.reverseDuration = Duration(milliseconds: 200);
    await _animationController.reverse();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primaryColor = Theme.of(Get.context!).primaryColor;
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeTransition(
          opacity: _animation,
          child: GestureDetector(
            onTap: handleCancel,
            child: Container(color: Color(0x55000000)),
          ),
        ),
        Positioned(
          top: (size.height - 400.w) * 0.4,
          width: 300.w,
          height: 400.w,
          child: MatrixTransition(
            animation: _animation,
            alignment: Alignment.topCenter,
            onTransform: (double value) {
              return Matrix4Tween(
                begin: _animation.status == AnimationStatus.forward
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
              opacity: _animation,
              child: Container(
                clipBehavior: Clip.hardEdge,
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: SfDateRangePicker(
                  cancelText: '取消',
                  confirmText: '确定',
                  headerHeight: 50.w,
                  onCancel: handleCancel,
                  onSubmit: handleConfirm,
                  maxDate: DateTime.now(),
                  showActionButtons: true,
                  showNavigationArrow: true,
                  initialSelectedRange: widget.value,
                  selectionColor: primaryColor,
                  todayHighlightColor: primaryColor,
                  endRangeSelectionColor: primaryColor,
                  startRangeSelectionColor: primaryColor,
                  selectionMode: DateRangePickerSelectionMode.range,
                  navigationDirection: DateRangePickerNavigationDirection.vertical,
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    backgroundColor: primaryColor,
                    textStyle: TextStyle(color: Colors.white, fontSize: 20.w),
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
