import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:qm/utils/qm_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QmInput extends StatefulWidget {
  final String value;
  final BoxShape shape;
  final double? height;
  final Color fillColor;
  final Widget? prefix;
  final bool allowClear;
  final String? placeholder;
  final double? borderRadius;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function()? onEditingComplete;
  final void Function(String value) onChanged;
  final void Function(String value)? onSubmitted;

  const QmInput({
    super.key,
    this.height,
    this.prefix,
    this.onSubmitted,
    this.placeholder,
    this.borderRadius,
    required this.value,
    this.onEditingComplete,
    required this.onChanged,
    this.allowClear = false,
    this.shape = BoxShape.circle,
    this.fillColor = Colors.white,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<QmInput> createState() => _QmInputState();
}

class _QmInputState extends State<QmInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  /// 清除 value
  clearValue() {
    /// 震动回馈
    hapticFeedback();
    widget.onChanged('');
    _controller.text = '';
    _focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(covariant QmInput oldWidget) {
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double borderRadius =
        widget.shape == BoxShape.circle ? (widget.height ?? 40.w) / 2 : widget.borderRadius ?? 20.w;
    return Container(
      height: widget.height ?? 40.w,
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: widget.prefix == null ? 0 : 10.w),
            child: widget.prefix,
          ),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              style: TextStyle(
                height: 1.2,
                fontSize: 14.w,
                color: Colors.black87,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: Theme.of(context).primaryColor,
              onEditingComplete: widget.onEditingComplete,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: TextStyle(color: Colors.black38),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.w),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: widget.allowClear ? 10.w : 0),
            child: widget.allowClear
                ? GestureDetector(
                    onTap: clearValue,
                    child: Opacity(
                      opacity: widget.value.isNotEmpty ? 1 : 0,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: Color(0xFFCCCCCC),
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        alignment: Alignment.center,
                        child: Icon(QmIcons.close2, size: 16.w, color: Colors.white),
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
