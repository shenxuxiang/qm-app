import 'package:get/get.dart';
import 'package:qm/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qm/entity/work_type.dart';
import 'package:qm/entity/crops_type.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:qm/models/work_info_models.dart';
import 'package:qm/components/button_widget.dart';
import 'package:qm/components/cascader/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class FilterButton extends StatefulWidget {
  final SelectedTreeNode? selectedCity;
  final CropsType? selectedCropsType;
  final WorkType? selectedWorkType;
  final DateType? selectedDateType;
  final DateTime? startTime;
  final DateTime? endTime;
  final void Function() onReset;
  final void Function(Map<String, dynamic> value) onSubmit;

  const FilterButton({
    this.selectedCropsType,
    this.selectedWorkType,
    this.selectedDateType,
    this.selectedCity,
    this.startTime,
    this.endTime,
    super.key,
    required this.onReset,
    required this.onSubmit,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  _handleChangeSelectedCity() {
    utils.BottomSheet.show(
      height: 600.w,
      builder: (BuildContext context, {Widget? child, required Future<void> Function() onClose}) {
        return _SearchForm(
          initialCropsType: widget.selectedCropsType,
          initialWorkType: widget.selectedWorkType,
          initialDateType: widget.selectedDateType,
          initialStartTime: widget.startTime,
          initialCity: widget.selectedCity,
          initialEndTime: widget.endTime,
          onConfirm: (value) async {
            await onClose();
            widget.onSubmit(value);
          },
          onReset: () async {
            await onClose();
            widget.onReset();
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
        utils.QmIcons.down,
        size: 14.w,
        color: Colors.black54,
      ),
      label: Text(
        '筛选',
        style: TextStyle(
          fontSize: 14.w,
          color: Colors.black54,
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

class _SearchForm extends StatefulWidget {
  final SelectedTreeNode? initialCity;
  final CropsType? initialCropsType;
  final DateTime? initialStartTime;
  final DateType? initialDateType;
  final WorkType? initialWorkType;
  final DateTime? initialEndTime;
  final void Function(Map<String, dynamic> value) onConfirm;
  final void Function() onReset;

  const _SearchForm({
    required this.onConfirm,
    required this.onReset,
    this.initialCropsType,
    this.initialStartTime,
    this.initialWorkType,
    this.initialDateType,
    this.initialEndTime,
    this.initialCity,
    super.key,
  });

  @override
  State<_SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<_SearchForm> {
  final endDate = Rx<DateTime?>(null);
  final startDate = Rx<DateTime?>(null);
  final selectedDateType = Rx<DateType?>(null);
  final selectedWorkType = Rx<WorkType?>(null);
  final selectedCropsType = Rx<CropsType?>(null);
  final selectedCity = Rx<SelectedTreeNode?>(null);
  final dateTypeList = [
    DateType(label: '全部', id: 'ALL'),
    DateType(label: '今天', value: PickerDateRange(DateTime.now(), DateTime.now()), id: 'TODAY'),
    DateType(
      label: '一周',
      value: PickerDateRange(DateTime.now().subtract(Duration(days: 7)), DateTime.now()),
      id: 'WEEk',
    ),
    DateType(
      label: '一月',
      value: PickerDateRange(DateTime.now().subtract(Duration(days: 30)), DateTime.now()),
      id: 'MONTH',
    ),
  ];

  @override
  initState() {
    endDate.value = widget.initialEndTime;
    selectedCity.value = widget.initialCity;
    startDate.value = widget.initialStartTime;
    selectedWorkType.value = widget.initialWorkType;
    selectedCropsType.value = widget.initialCropsType;
    selectedDateType.value = widget.initialDateType ?? dateTypeList[0];
    super.initState();
  }

  handleConfirm() {
    widget.onConfirm({
      'endTime': endDate.value,
      'startTime': startDate.value,
      'selectedCity': selectedCity.value,
      'selectedDateType': selectedDateType.value,
      'selectedWorkType': selectedWorkType.value,
      'selectedCropsType': selectedCropsType.value,
    });
  }

  handleChangeCity() {
    utils.BottomSheet.show(
      height: 600.w,
      builder: (BuildContext context, {Widget? child, required VoidCallback onClose}) {
        return CasCadeWidget(
          placeholder: '请选择所在地区',
          sourceList: Get.find<MainModels>().regionList,
          onConfirm: (List<SelectedTreeNode> value) {
            selectedCity.value = value.last;
            onClose();
          },
        );
      },
    );
  }

  handleChangeTime() async {
    PickerDateRange? result = await utils.DateRangePicker.show(
      value: PickerDateRange(startDate.value, endDate.value),
    );
    if (result != null) {
      endDate.value = result.endDate!;
      startDate.value = result.startDate!;
      selectedDateType.value = dateTypeList[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainModels = Get.find<MainModels>();
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      height: 600.w,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _renderTitle('作业地点'),
          Obx(
            () => ElevatedButton.icon(
              onPressed: handleChangeCity,
              label: Text(
                selectedCity.value != null ? selectedCity.value!.label : '作业地点',
                style: TextStyle(
                  fontSize: 13.w,
                  color: selectedCity.value != null ? primaryColor : Colors.black54,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                maximumSize: Size(160.w, 40.w),
                minimumSize: Size(160.w, 40.w),
                backgroundColor: Color(0xFFE9E9E9),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.w)),
              ),
              iconAlignment: IconAlignment.end,
              icon: Icon(
                utils.QmIcons.down,
                color: selectedCity.value != null ? primaryColor : Colors.black54,
              ),
            ),
          ),
          Container(height: 1, margin: EdgeInsets.symmetric(vertical: 10.w), color: Colors.black12),
          _renderTitle('作业类型'),
          Obx(
            () => Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 10.w,
              runSpacing: 10.w,
              children: [
                GestureDetector(
                  onTap: () => selectedWorkType.value = null,
                  child: Container(
                    width: 74.5.w,
                    height: 46.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: selectedWorkType.value == null ? primaryColor : Color(0xFFE9E9E9),
                    ),
                    child: Text(
                      '全部',
                      style: TextStyle(
                        fontSize: 13.w,
                        color: selectedWorkType.value == null ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ),
                for (final workType in mainModels.workTypeList)
                  GestureDetector(
                    onTap: () => selectedWorkType.value = workType,
                    child: Container(
                      width: 74.5.w,
                      height: 46.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        color:
                            selectedWorkType.value == workType ? primaryColor : Color(0xFFE9E9E9),
                      ),
                      child: Text(
                        workType.label,
                        style: TextStyle(
                          fontSize: 12.w,
                          color: selectedWorkType.value == workType ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Container(height: 1, margin: EdgeInsets.symmetric(vertical: 10.w), color: Colors.black12),
          _renderTitle('作业季'),
          GestureDetector(
            onTap: handleChangeTime,
            child: Container(
              width: double.infinity,
              height: 40.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.w),
                color: Color(0xFFE9E9E9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(
                    () => Text(
                      startDate.value == null
                          ? '开始时间'
                          : utils.formatDateTime(startDate.value!, 'YYYY-MM-DD'),
                      style: TextStyle(
                        fontSize: 13.w,
                        color: startDate.value != null ? primaryColor : Colors.black54,
                      ),
                    ),
                  ),
                  Text('--'),
                  Obx(
                    () => Text(
                      endDate.value == null
                          ? '结束时间'
                          : utils.formatDateTime(endDate.value!, 'YYYY-MM-DD'),
                      style: TextStyle(
                        fontSize: 13.w,
                        color: endDate.value != null ? primaryColor : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.w),
          Obx(
            () => Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 10.w,
              runSpacing: 10.w,
              children: [
                for (DateType item in dateTypeList)
                  GestureDetector(
                    onTap: () {
                      selectedDateType.value = item;
                      endDate.value = item.value?.endDate;
                      startDate.value = item.value?.startDate;
                    },
                    child: Container(
                      width: 74.5.w,
                      height: 46.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        color: selectedDateType.value?.id == item.id
                            ? primaryColor
                            : Color(0xFFE9E9E9),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12.w,
                          color:
                              selectedDateType.value?.id == item.id ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Container(height: 1, margin: EdgeInsets.symmetric(vertical: 10.w), color: Colors.black12),
          _renderTitle('农作物'),
          Obx(
            () => Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              spacing: 10.w,
              runSpacing: 10.w,
              children: [
                GestureDetector(
                  onTap: () => selectedCropsType.value = null,
                  child: Container(
                    width: 74.5.w,
                    height: 46.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: selectedCropsType.value == null ? primaryColor : Color(0xFFE9E9E9),
                    ),
                    child: Text(
                      '全部',
                      style: TextStyle(
                        fontSize: 13.w,
                        color: selectedCropsType.value == null ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ),
                for (final cropsType in mainModels.cropsTypeList)
                  GestureDetector(
                    onTap: () => selectedCropsType.value = cropsType,
                    child: Container(
                      width: 74.5.w,
                      height: 46.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        color:
                            selectedCropsType.value == cropsType ? primaryColor : Color(0xFFE9E9E9),
                      ),
                      child: Text(
                        cropsType.label,
                        style: TextStyle(
                          fontSize: 13.w,
                          color:
                              selectedCropsType.value == cropsType ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 1, margin: EdgeInsets.symmetric(vertical: 10.w), color: Colors.black12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ButtonWidget(
                  onPressed: widget.onReset,
                  width: 100.w,
                  height: 40.w,
                  text: '重置',
                  ghost: true,
                ),
                ButtonWidget(
                  onPressed: handleConfirm,
                  width: 100.w,
                  height: 40.w,
                  text: '确定',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _renderTitle(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.w),
    child: Text(
      title,
      style: TextStyle(
        height: 1,
        fontSize: 14.w,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
