import 'package:get/get.dart';
import 'package:qm/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:qm/components/cascader/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectCity extends StatelessWidget {
  final SelectedTreeNode? value;
  final void Function(SelectedTreeNode? value) onSelected;

  const SelectCity({super.key, required this.onSelected, this.value});

  _handleChangeSelectedCity() {
    utils.BottomSheet.show(
      height: 600.w,
      builder: (BuildContext context, {Widget? child, required VoidCallback onClose}) {
        return CasCadeWidget(
          placeholder: '请选择所在地区',
          sourceList: Get.find<MainModels>().regionList,
          onConfirm: (List<SelectedTreeNode> value) {
            onSelected(value.last);
            onClose();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return TextButton.icon(
      onPressed: _handleChangeSelectedCity,
      iconAlignment: IconAlignment.end,
      icon: Icon(
        value != null ? utils.QmIcons.up : utils.QmIcons.down,
        size: 14.w,
        color: value != null ? primaryColor : Colors.black54,
      ),
      label: Text(
        value == null ? '城市' : value!.label,
        style: TextStyle(
          fontSize: 14.w,
          color: value != null ? primaryColor : Colors.black54,
        ),
      ),
      style: TextButton.styleFrom(
        overlayColor: Colors.transparent,
        maximumSize: Size.fromWidth(110.w),
        minimumSize: Size.fromWidth(110.w),
        padding: EdgeInsets.symmetric(horizontal: 0),
      ),
    );
  }
}
