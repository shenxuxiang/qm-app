import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:qm/utils/index.dart';
import 'package:qm/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qm/api/main.dart' as api;
import 'package:qm/common/base_page.dart';
import 'package:qm/entity/work_type.dart';
import 'package:qm/entity/crops_type.dart';
import 'package:qm/components/button_widget.dart';
import 'package:qm/entity/driver_work_params.dart';
import 'package:qm/components/skeleton_screen.dart';
import 'package:qm/models/connect_device_models.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:qm/components/select_drive_work_Type.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkTypePage extends BasePage {
  const WorkTypePage({super.key, required super.title});

  @override
  BasePageState<WorkTypePage> createState() => _WorkTypePageState();
}

class _WorkTypePageState extends BasePageState<WorkTypePage> {
  bool _isLoading = true;

  /// 手机型号
  String _deviceModel = '';
  late DriveWorkType _driveWorkType;

  /// 是否有终端设备
  final bool _hasDevice = Get.parameters['hasDevice']?.isNotEmpty ?? false;

  void handleChangeDriveWorkType(DriveWorkType value) {
    _driveWorkType = value;
  }

  handleConfirm() {
    final reg = RegExp(r'^\d+(\.\d+)?$');
    if (_driveWorkType.workWidth.isEmpty) {
      Toast.show('请填写作业幅宽');
      return;
    } else if (!reg.hasMatch(_driveWorkType.workWidth)) {
      Toast.show('请填写正确的作业幅宽');
      return;
    }

    if (_driveWorkType.workType == null) {
      Toast.show('请选择作业类型');
      return;
    }

    if (_driveWorkType.cropsType == null) {
      Toast.show('请选择农作物类型');
      return;
    }

    final result = DriverWorkParams(
      phoneModel: _deviceModel,
      deviceCode: 'HuaWei Meta 60',
      workTypeId: _driveWorkType.workType!.value,
      workSeason: _driveWorkType.cropsType!.value,
      workWidth: double.parse(_driveWorkType.workWidth),
    );

    if (_hasDevice) {
      Get.toNamed('/connect_device', arguments: result);
    } else {
      Get.find<ConnectDeviceModels>().onChangedDriverWorkParams(result);
      Get.back();
    }
  }

  handleGoBack() {
    Get.find<ConnectDeviceModels>().onChangedDriverWorkParams(null);
    Get.back();
  }

  @override
  void initState() {
    super.initState();

    /// 获取设备型号
    final deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      deviceInfoPlugin.androidInfo.then((AndroidDeviceInfo info) {
        _deviceModel = info.model;
      });
    } else {
      deviceInfoPlugin.iosInfo.then((IosDeviceInfo info) {
        _deviceModel = info.model;
      });
    }

    try {
      final mainModels = Get.find<MainModels>();
      List<Future> futures = [];
      _isLoading = mainModels.cropsTypeList.isEmpty || mainModels.workTypeList.isEmpty;

      /// 初始化农作物
      if (mainModels.cropsTypeList.isEmpty) {
        final p1 = api.queryCropsTypeList().then((resp) {
          List<CropsType> cropsTypeList = [
            for (final item in resp.data) CropsType(label: item['dictName'], value: item['value'])
          ];
          mainModels.setCropsTypeList(cropsTypeList);
        });

        futures.add(p1);
      }

      /// 初始化作业类型
      if (mainModels.workTypeList.isEmpty) {
        final p2 = api.queryWorkTypeList().then((resp) {
          List<WorkType> workTypeList = [
            for (final item in resp.data)
              WorkType(label: item['jobTypeName'], value: item['jobTypeId'])
          ];
          mainModels.setWorkTypeList(workTypeList);
        });

        futures.add(p2);
      }

      Future.wait(futures).then((resp) {
        setState(() => _isLoading = false);
      });
    } catch (error, stack) {
      debugPrint('error: $error');
      debugPrint('stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return SkeletonScreen(title: widget.title);

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: GestureDetector(onTap: handleGoBack, child: Icon(QmIcons.back)),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              child: SelectDriveWorkType(onChanged: handleChangeDriveWorkType),
            ),
            Container(
              width: 260.w,
              padding: EdgeInsets.only(bottom: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ButtonWidget(
                    text: '取消',
                    ghost: true,
                    width: 100.w,
                    type: 'default',
                    onPressed: handleGoBack,
                  ),
                  ButtonWidget(
                    text: '确认',
                    width: 100.w,
                    onPressed: handleConfirm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
