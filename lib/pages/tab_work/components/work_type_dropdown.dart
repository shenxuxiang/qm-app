import 'package:get/get.dart';
import 'package:qmnj/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/entity/work_type.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:qmnj/components/dropdown_menu_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkTypeDropdown extends StatefulWidget {
  final Function(WorkType? value) onSelected;
  final WorkType? value;

  const WorkTypeDropdown({super.key, required this.onSelected, this.value});

  @override
  State<WorkTypeDropdown> createState() => _WorkTypeDropdownState();
}

class _WorkTypeDropdownState extends State<WorkTypeDropdown> {
  WorkType? _selectedWorkType;

  handleChangeWorkType(WorkType? value) {
    setState(() => _selectedWorkType = value);
    widget.onSelected(value);
  }

  @override
  void didUpdateWidget(covariant WorkTypeDropdown oldWidget) {
    if (_selectedWorkType != widget.value) {
      setState(() => _selectedWorkType = widget.value);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final mainModels = Get.find<MainModels>();
    final primaryColor = Theme.of(context).primaryColor;
    return Obx(
      () => DropdownMenuButton<WorkType>(
        maxWidth: 200.w,
        maxHeight: 350.w,
        menuItemHeight: 50.w,
        dropdownPadding: EdgeInsets.zero,
        itemCount: mainModels.workTypeList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return PopupMenuItem(
              height: 40.w,
              padding: EdgeInsets.all(0),
              value: null,
              onTap: () => handleChangeWorkType(null),
              child: Container(
                width: 200.w,
                height: 50.w,
                color: _selectedWorkType == null ? primaryColor : Color(0xFFF9F9F9),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  '全部',
                  style: TextStyle(
                    fontSize: 14.w,
                    color: _selectedWorkType == null ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }
          return PopupMenuItem(
            height: 40.w,
            padding: EdgeInsets.all(0),
            value: mainModels.workTypeList[index - 1],
            onTap: () => handleChangeWorkType(mainModels.workTypeList[index - 1]),
            child: Container(
              width: 200.w,
              height: 50.w,
              color: _selectedWorkType == mainModels.workTypeList[index - 1]
                  ? primaryColor
                  : Color(0xFFF9F9F9),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                mainModels.workTypeList[index - 1].label,
                style: TextStyle(
                  fontSize: 14.w,
                  color: _selectedWorkType == mainModels.workTypeList[index - 1]
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          );
        },
        child: TextButton.icon(
          onPressed: null,
          iconAlignment: IconAlignment.end,
          icon: Icon(
            _selectedWorkType != null ? utils.QmIcons.up : utils.QmIcons.down,
            size: 14.w,
            color: _selectedWorkType != null ? primaryColor : Colors.black54,
          ),
          label: Text(
            _selectedWorkType?.label ?? '作业类型',
            style: TextStyle(
              fontSize: 14.w,
              color: _selectedWorkType != null ? primaryColor : Colors.black54,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 0),
            overlayColor: Colors.transparent,
            maximumSize: Size.fromWidth(110.w),
            minimumSize: Size.fromWidth(110.w),
          ),
        ),
      ),
    );
  }
}
