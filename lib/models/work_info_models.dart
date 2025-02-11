import 'package:get/get.dart';
import 'package:qmnj/entity/work_type.dart';
import 'package:qmnj/entity/crops_type.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateType {
  final String id;
  final String label;
  final PickerDateRange? value;

  const DateType({required this.id, this.value, required this.label});
}

class WorkInfoModels extends GetxController {
  final endDate = Rx<DateTime?>(null);
  final startDate = Rx<DateTime?>(null);
  final selectedDataType = Rx<DateType?>(null);
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

  final selectedWorkType = Rx<WorkType?>(null);
  final selectedCropsType = Rx<CropsType?>(null);

  @override
  void onInit() {
    selectedDataType.value = dateTypeList[2];
    endDate.value = dateTypeList[2].value!.endDate;
    startDate.value = dateTypeList[2].value!.startDate;
    super.onInit();
  }
}
