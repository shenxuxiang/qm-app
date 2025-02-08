import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final double size;
  final Color color;

  const EmptyWidget({super.key, this.size = 40, this.color = Colors.black38});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(utils.QmIcons.empty, size: size, color: color),
        SizedBox(height: 12.w),
        Text(
          '暂无数据',
          style: TextStyle(
            height: 1,
            color: color,
            fontSize: size * 0.35,
          ),
        ),
      ],
    );
  }
}
