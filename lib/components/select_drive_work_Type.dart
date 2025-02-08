import 'package:get/get.dart';
import 'package:qm/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qm/api/main.dart' as api;
import 'package:qm/entity/work_type.dart';
import 'package:qm/entity/crops_type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget _renderMenuItem<T>({
  required T value,
  required bool active,
  required String label,
  required BuildContext context,
  required Function(T value) onTap,
}) {
  return GestureDetector(
    onTap: () => onTap(value),
    child: Container(
      height: 44.w,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        color: active ? Theme.of(context).primaryColor : Colors.black12,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 14.w, height: 1, color: active ? Colors.white : Colors.black38),
      ),
    ),
  );
}

class DriveWorkType {
  final String workWidth;
  final WorkType? workType;
  final CropsType? cropsType;

  DriveWorkType({required this.workWidth, required this.cropsType, required this.workType});
}

class SelectDriveWorkType extends StatefulWidget {
  final Function(DriveWorkType value) onChanged;

  const SelectDriveWorkType({super.key, required this.onChanged});

  @override
  State<SelectDriveWorkType> createState() => _SelectDriveWorkTypeState();
}

class _SelectDriveWorkTypeState extends State<SelectDriveWorkType> {
  final _workWidth = '6'.obs;
  final _selectedWorkType = Rx<WorkType?>(null);
  final _selectedCropsType = Rx<CropsType?>(null);

  late final TextEditingController _textEditingController;

  handleChangeDriveWorkType() {
    widget.onChanged(DriveWorkType(
      workWidth: _workWidth.value,
      workType: _selectedWorkType.value,
      cropsType: _selectedCropsType.value,
    ));
  }

  handleChangeWorkWidth(String value) {
    _workWidth.value = value;
    handleChangeDriveWorkType();
  }

  handleChangeWorkType(WorkType value) {
    _selectedWorkType.value = value;
    handleChangeDriveWorkType();
  }

  handleChangeCropsType(CropsType value) {
    _selectedCropsType.value = value;
    handleChangeDriveWorkType();
  }

  @override
  void initState() {
    _textEditingController = TextEditingController(text: _workWidth.value);

    final mainModels = Get.find<MainModels>();

    /// 初始化农作物
    if (mainModels.cropsTypeList.isEmpty) {
      api.queryCropsTypeList().then((resp) {
        List<CropsType> cropsTypeList = [
          for (final item in resp.data) CropsType(label: item['dictName'], value: item['value'])
        ];
        mainModels.setCropsTypeList(cropsTypeList);
        handleChangeCropsType(cropsTypeList[0]);
      });
    } else {
      handleChangeCropsType(mainModels.cropsTypeList[0]);
    }

    /// 初始化作业类型
    if (mainModels.workTypeList.isEmpty) {
      api.queryWorkTypeList().then((resp) {
        List<WorkType> workTypeList = [
          for (final item in resp.data)
            WorkType(label: item['jobTypeName'], value: item['jobTypeId'])
        ];
        mainModels.setWorkTypeList(workTypeList);
        handleChangeWorkType(workTypeList[0]);
      });
    } else {
      handleChangeWorkType(mainModels.workTypeList[0]);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mainModels = Get.find<MainModels>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '选择农作物',
          style: TextStyle(fontSize: 14.w, color: Colors.black87, height: 2),
        ),
        SizedBox(height: 10.w),
        Obx(
          () => Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            runSpacing: 10.w,
            spacing: 10.w,
            children: [
              for (CropsType item in mainModels.cropsTypeList)
                _renderMenuItem(
                  value: item,
                  context: context,
                  label: item.label,
                  onTap: handleChangeCropsType,
                  active: item == _selectedCropsType.value,
                )
            ],
          ),
        ),
        SizedBox(height: 20.w),
        Text(
          '选择作业类型',
          style: TextStyle(fontSize: 14.w, color: Colors.black87, height: 2),
        ),
        SizedBox(height: 10.w),
        Obx(
          () => Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            runSpacing: 10.w,
            spacing: 10.w,
            children: [
              for (WorkType item in mainModels.workTypeList)
                _renderMenuItem(
                  value: item,
                  context: context,
                  label: item.label,
                  onTap: handleChangeWorkType,
                  active: item == _selectedWorkType.value,
                )
            ],
          ),
        ),
        SizedBox(height: 20.w),
        Text(
          '输入作业幅宽',
          style: TextStyle(fontSize: 14.w, color: Colors.black87, height: 2),
        ),
        SizedBox(height: 10.w),
        Row(
          children: [
            SizedBox(
              width: 120.w,
              child: TextField(
                textAlign: TextAlign.center,
                onChanged: handleChangeWorkWidth,
                controller: _textEditingController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(fontSize: 15.w, color: Colors.black87, height: 1.2),
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: '输入作业幅宽',
                  hintStyle: TextStyle(fontSize: 15.w, color: Colors.black26, height: 1.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.w),
                    borderSide: BorderSide(width: 1, color: Colors.black38),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black38),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10.w)),
            Text(
              '米',
              style: TextStyle(fontSize: 15.w, color: Colors.black54, height: 1.2),
            ),
          ],
        ),
      ],
    );
  }
}
