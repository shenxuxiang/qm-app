import 'package:flutter/material.dart';

class KeepAliveWidget extends StatefulWidget {
  final Widget child;
  final bool keepAlive;

  const KeepAliveWidget({super.key, this.keepAlive = true, required this.child});

  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(covariant KeepAliveWidget oldWidget) {
    if (widget.keepAlive != oldWidget.keepAlive) {
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }
}
