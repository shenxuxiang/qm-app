import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:amap_map/amap_map.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:qmnj/common/base_page.dart';
import 'package:x_amap_base/x_amap_base.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:qmnj/components/skeleton_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkDetail extends BasePage {
  const WorkDetail({super.key, super.title});

  @override
  BasePageState<WorkDetail> createState() => _WorkDetailState();
}

class _WorkDetailState extends BasePageState<WorkDetail> {
  Map<String, dynamic> _resourceData = {};
  bool _isPageLoading = true;

  final Map<String, String> _filterMaps = {
    '机手姓名': 'driver',
    '证件号码': 'driverIdNumber',
    '服务主体': 'organizationName',
    '开始时间': 'createTime',
    '结束时间': 'workEndTime',
    '作业地点': 'regionName',
    '农作物': 'workSeasonDesc',
    '作业类型': 'workType',
    '作业面积（亩）': 'area',
    '作业历程（公里）': 'mileage',
  };

  Set<Marker> _markers = {};
  Set<Polyline> _polyLines = {};
  CameraPosition _initialCameraPosition = CameraPosition(target: LatLng(0, 0), zoom: 10);

  @override
  initState() {
    api.queryDriveWorkDetail({'workId': Get.arguments}).then((resp) {
      final data = resp.data;
      List<dynamic> features = data?['points']?['features'] ?? [];

      List<LatLng> points = [];
      for (final feature in features) {
        final [lng, lat] = feature['geometry']['coordinates'];
        points.add(LatLng(lat, lng));
      }

      setState(() {
        _resourceData = data;
        _isPageLoading = false;
        _initialCameraPosition = CameraPosition(target: points[0], zoom: 13);
        _markers = {
          Marker(
            position: points[0],
            icon: BitmapDescriptor.fromIconPath('assets/images/start-point.png'),
          )
        };
        _polyLines = {
          Polyline(
            width: 6.w,
            points: points,
            capType: CapType.round,
            color: Color(0xFFFF4949),
          )
        };
      });
    });

    super.initState();
  }

  handleGoBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    AMapInitializer.init(context);
    if (_isPageLoading) return SkeletonScreen(title: '作业详情');

    return Scaffold(
      appBar: AppBar(
        title: Text('作业详情'),
        leading: GestureDetector(onTap: handleGoBack, child: Icon(utils.QmIcons.back)),
      ),
      body: Column(children: [
        SizedBox(
          width: double.infinity,
          height: 300.w,
          child: AMapWidget(
            markers: _markers,
            polylines: _polyLines,
            mapType: MapType.satellite,
            initialCameraPosition: _initialCameraPosition,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                for (final entry in _filterMaps.entries)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12.w),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.black12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}：',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 16.w,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _resourceData[entry.value].toString(),
                              // textAlign: TextAlign.right,
                              style: TextStyle(
                                height: 1.5,
                                fontSize: 16.w,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
