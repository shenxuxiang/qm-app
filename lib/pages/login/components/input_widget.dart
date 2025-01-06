import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputWidget extends StatefulWidget {
  final String value;
  final Widget? suffix;
  final Widget? prefix;
  final int? maxLength;
  final bool obscureText;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String value) onChanged;

  const InputWidget({
    super.key,
    this.prefix,
    this.suffix,
    this.placeholder,
    required this.value,
    required this.onChanged,
    this.maxLength = 9999999,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final double _height = 40.w;
  final double _fontSize = 15.sp;
  late final TextEditingController _controller;
  final EdgeInsets _contentPadding = EdgeInsets.symmetric(vertical: (40.w - 15.sp) / 2);

  @override
  void initState() {
    _controller = TextEditingController(text: widget.value);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InputWidget oldWidget) {
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Color(0xFFcfd8fc),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: widget.prefix == null
                ? EdgeInsets.only(left: 12.w)
                : EdgeInsets.symmetric(horizontal: 12.w),
            child: widget.prefix,
          ),
          Expanded(
            child: TextField(
              maxLines: 1,
              autofocus: false,
              controller: _controller,
              cursorColor: Colors.blue,
              maxLength: widget.maxLength,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textAlignVertical: TextAlignVertical.center,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              onChanged: (String value) => widget.onChanged(value),
              style: TextStyle(
                height: 1,
                fontSize: _fontSize,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintMaxLines: 1,
                // 不展示 maxLength
                counterText: '',
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                contentPadding: _contentPadding,
                hintStyle: TextStyle(color: Colors.black26),
              ),
            ),
          ),
          Padding(
            padding: widget.suffix == null
                ? EdgeInsets.only(right: 12.w)
                : EdgeInsets.symmetric(horizontal: 12.w),
            child: widget.suffix,
          ),
        ],
      ),
    );
  }
}
