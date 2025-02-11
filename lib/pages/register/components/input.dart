import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Input extends StatefulWidget {
  final String title;
  final String value;
  final Widget? suffix;
  final bool obscureText;
  final String? placeholder;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String value) onChanged;

  const Input({
    super.key,
    this.suffix,
    this.placeholder,
    required this.title,
    required this.value,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.number,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late final TextEditingController _controller;

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
  void didUpdateWidget(covariant Input oldWidget) {
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.sp,
              height: 1,
              // fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  style: TextStyle(
                    letterSpacing: widget.obscureText ? 10 : 0.5,
                    color: Colors.black87,
                    fontSize: 13.sp,
                    height: 1,
                  ),
                  cursorColor: themeData.primaryColor,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 0, right: 0, top: 16.w, bottom: 12.w),
                    hintStyle: TextStyle(
                        color: Colors.black38, letterSpacing: 0.5, fontSize: 13.w, height: 1),
                    hintText: widget.placeholder,
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintMaxLines: 1,
                  ),
                ),
              ),
              Padding(
                padding: widget.suffix == null ? EdgeInsets.zero : EdgeInsets.only(left: 12.w),
                child: widget.suffix,
              ),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Color(0xffdddddd),
          ),
        ],
      ),
    );
  }
}
