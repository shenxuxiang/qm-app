import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef DropdownMenuBuilder<T> = Widget Function(T menu);

class DropdownMenu<T> extends StatefulWidget {
  final Widget child;
  final List<T> menus;
  final double maxWidth;
  final double maxHeight;
  final double menuItemHeight;
  final Function(T menu) onSelected;
  final DropdownMenuBuilder<T> buildMenuItem;

  const DropdownMenu({
    super.key,
    required this.menus,
    required this.child,
    this.maxWidth = 260,
    this.maxHeight = 300,
    required this.onSelected,
    this.menuItemHeight = 40,
    required this.buildMenuItem,
  });

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
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

    double dropdownHeight = math.min(widget.maxHeight, widget.menus.length * widget.menuItemHeight);
    if (offset.dy + dropdownHeight + 20 > ancestorBox.size.height) {
      position = RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + dropdownHeight + 10,
        ancestorBox.size.width,
        offset.dy + 10,
      );
    }
    showMenu(
      context: context,
      position: position,
      items: [
        for (final menu in widget.menus)
          PopupMenuItem(
            value: menu,
            height: widget.menuItemHeight,
            onTap: () => widget.onSelected(menu),
            child: widget.buildMenuItem(menu),
          ),
      ],
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
