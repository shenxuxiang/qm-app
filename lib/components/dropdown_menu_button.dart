import 'dart:math' as math;
import 'package:flutter/material.dart';

class DropdownMenuButton<T> extends StatefulWidget {
  final Widget child;
  final int itemCount;
  final double maxWidth;
  final double maxHeight;
  final double menuItemHeight;
  final Color dropdownBackground;
  final EdgeInsets dropdownPadding;
  final PopupMenuEntry<T> Function(BuildContext context, int index) itemBuilder;

  const DropdownMenuButton({
    super.key,
    required this.child,
    this.maxWidth = 260,
    this.maxHeight = 300,
    required this.itemCount,
    this.menuItemHeight = 40,
    required this.itemBuilder,
    this.dropdownBackground = Colors.white,
    this.dropdownPadding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  State<DropdownMenuButton> createState() => _DropdownMenuButtonState();
}

class _DropdownMenuButtonState<T> extends State<DropdownMenuButton<T>> {
  void _handleShowDropdown(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final ancestorBox = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: ancestorBox);
    final width = renderBox.size.width;
    final height = renderBox.size.height;

    RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(offset.dx, offset.dy + height, width, height),
      Offset.zero & ancestorBox.size,
    );

    double dropdownHeight = math.min(widget.maxHeight, widget.itemCount * widget.menuItemHeight);
    if (offset.dy + dropdownHeight + 20 > ancestorBox.size.height) {
      position = RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 10 - dropdownHeight,
        ancestorBox.size.width,
        offset.dy - 10,
      );
    }

    List<PopupMenuEntry> items = [];
    for (int i = 0; i < widget.itemCount; i++) {
      items.add(widget.itemBuilder(context, i));
    }

    showMenu(
      items: items,
      elevation: 5,
      context: context,
      position: position,
      clipBehavior: Clip.hardEdge,
      color: widget.dropdownBackground,
      menuPadding: widget.dropdownPadding,
      constraints: BoxConstraints(maxHeight: widget.maxHeight, maxWidth: widget.maxWidth),
      popUpAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 150),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleShowDropdown(context),
      child: widget.child,
    );
  }
}
