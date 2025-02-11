import 'package:flutter/material.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpansionPanelWidget extends StatefulWidget {
  final Widget body;
  final bool? opened;
  final Widget header;
  final EdgeInsets bodyPadding;
  final EdgeInsets headerPadding;
  final void Function(bool)? onOpen;
  final BoxDecoration bodyDecoration;
  final BoxDecoration headerDecoration;

  const ExpansionPanelWidget({
    super.key,
    this.opened,
    this.onOpen,
    required this.body,
    required this.header,
    this.headerDecoration = const BoxDecoration(color: Colors.white),
    this.bodyDecoration = const BoxDecoration(color: Color(0xFFE9E9E9)),
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.bodyPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  });

  @override
  State<ExpansionPanelWidget> createState() => _ExpansionPanelState();
}

class _ExpansionPanelState extends State<ExpansionPanelWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _opened = false;

  @override
  void didUpdateWidget(covariant ExpansionPanelWidget oldWidget) {
    if (oldWidget.opened != widget.opened) {
      _opened = widget.opened ?? false;

      if (_opened) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _opened = widget.opened ?? false;
    if (_opened) _controller.forward();
    super.initState();
  }

  handleTrigger() async {
    if (_opened) {
      await _controller.reverse();
      _opened = false;
    } else {
      await _controller.forward();
      _opened = true;
    }
    if (widget.onOpen != null) widget.onOpen!(_opened);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: handleTrigger,
          child: Container(
            height: 50.w,
            decoration: widget.headerDecoration,
            width: double.infinity,
            padding: widget.headerPadding,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(_animation),
                  child: Icon(utils.QmIcons.down, size: 18.w, color: Colors.black38),
                ),
                SizedBox(width: 10.w),
                DefaultTextStyle(
                  style: TextStyle(fontSize: 15.w, color: Colors.black87, height: 1),
                  child: widget.header,
                ),
              ],
            ),
          ),
        ),
        Container(width: double.infinity, height: 1, color: Colors.black12),
        SizeTransition(
          sizeFactor: _animation,
          child: Container(
            width: double.infinity,
            decoration: widget.bodyDecoration,
            padding: widget.bodyPadding,
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 14.w, height: 1.5, color: Colors.black54),
              child: widget.body,
            ),
          ),
        ),
      ],
    );
  }
}
