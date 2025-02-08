import 'dart:async';
import 'package:get/get.dart';
import 'package:qm/models/main.dart';
import 'package:flutter/material.dart';
import 'components/drive_work_item.dart';
import 'package:qm/api/main.dart' as api;
import 'package:qm/entity/work_type.dart';
import 'package:qm/entity/crops_type.dart';
import 'components/work_type_dropdown.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:qm/models/work_info_models.dart';
import 'package:qm/components/cascader/index.dart';
import 'package:qm/components/skeleton_screen.dart';
import 'package:qm/components/easy_refresh_footer.dart';
import 'package:qm/components/sliver_header_delegate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qm/pages/tab_work/components/select_city.dart';
import 'package:qm/pages/tab_work/components/filter_button.dart';

class TabWork extends StatefulWidget {
  const TabWork({super.key});

  @override
  State<TabWork> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabWork> {
  SelectedTreeNode? _selectedCity;
  CropsType? _selectedCropsType;
  WorkType? _selectedWorkType;
  DateType? _selectedDateType;
  DateTime? _startTime;
  DateTime? _endTime;
  int _pageNum = 1;
  bool _noMore = false;
  final int _pageSize = 10;
  bool _isPageLoading = true;
  List<dynamic> _resourceList = [];
  late final EasyRefreshController _easyRefreshController;
  late final ScrollController _scrollController;

  /// 数据刷新
  Future<void> refreshResourceList() async {
    _pageNum = 1;

    final resp = await api.queryDriveWorkList({
      'pageNum': _pageNum,
      'pageSize': _pageSize,
      'regionCode': _selectedCity?.value ?? '',
      'workTypeId': _selectedWorkType?.value ?? '',
      'workSeason': _selectedCropsType?.value ?? '',
      'endTime': _endTime != null ? utils.formatDateTime(_endTime!) : '',
      'startTime': _startTime != null ? utils.formatDateTime(_startTime!) : '',
    });
    setState(() {
      _resourceList = resp.data['list'] ?? [];
      _noMore = _resourceList.length >= resp.data['total'];
    });
  }

  /// 初始化数据
  void initialResource() async {
    final mainModels = Get.find<MainModels>();
    Get.put<WorkInfoModels>(WorkInfoModels());

    List<Future> futures = [];

    if (mainModels.regionList.isEmpty) {
      final p1 = api.queryRegionList({}).then((resp) {
        Get.find<MainModels>().setRegionList(resp.data);
      });
      futures.add(p1);
    }

    /// 初始化农作物类型
    if (mainModels.cropsTypeList.isEmpty) {
      final p2 = api.queryCropsTypeList().then((resp) {
        List<CropsType> cropsTypeList = [
          for (final item in resp.data) CropsType(label: item['dictName'], value: item['value'])
        ];

        debugPrint('resp: ${resp.data}');
        mainModels.setCropsTypeList(cropsTypeList);
      });
      futures.add(p2);
    }

    /// 初始化作业类型
    if (mainModels.workTypeList.isEmpty) {
      final p3 = api.queryWorkTypeList().then((resp) {
        List<WorkType> workTypeList = [
          for (final item in resp.data)
            WorkType(label: item['jobTypeName'], value: item['jobTypeId'])
        ];
        mainModels.setWorkTypeList(workTypeList);
      });
      futures.add(p3);
    }

    final p4 = refreshResourceList();
    futures.add(p4);
    await Future.wait(futures);
    setState(() => _isPageLoading = false);
  }

  /// 刷新数据
  Future handleRefresh() async {
    _scrollController.jumpTo(0);
    utils.Loading.show(text: '数据加载中');
    try {
      await refreshResourceList();
      IndicatorResult result = _noMore ? IndicatorResult.noMore : IndicatorResult.success;
      _easyRefreshController.finishLoad(result);
    } catch (error) {
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }
    utils.Loading.hide();
  }

  /// 加载更多数据
  Future handleLoad() async {
    if (_noMore) {
      _easyRefreshController.finishLoad(IndicatorResult.noMore);
    }

    try {
      final resp = await api.queryDriveWorkList({
        'regionCode': _selectedCity?.value ?? '',
        'workTypeId': _selectedWorkType?.value ?? '',
        'startTime': _startTime != null ? utils.formatDateTime(_startTime!) : '',
        'endTime': _endTime != null ? utils.formatDateTime(_endTime!) : '',
        'workSeaon': _selectedCropsType?.value ?? '',
        'pageSize': _pageSize + 1,
        'pageNum': _pageNum,
      });

      setState(() {
        _pageNum = resp.data['pageNum'];
        _resourceList.addAll(resp.data['list'] ?? []);
        _noMore = _resourceList.length >= resp.data['total'];
      });
      IndicatorResult result = _noMore ? IndicatorResult.noMore : IndicatorResult.success;
      _easyRefreshController.finishLoad(result);
    } catch (error) {
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }
  }

  /// 表单筛选提交
  handleSubmit(value) {
    setState(() {
      _selectedCropsType = value['selectedCropsType'];
      _selectedWorkType = value['selectedWorkType'];
      _selectedDateType = value['selectedDateType'];
      _selectedCity = value['selectedCity'];
      _startTime = value['startTime'];
      _endTime = value['endTime'];
    });

    handleRefresh();
  }

  /// 表单重置提交
  handleReset() {
    setState(() {
      _selectedCropsType = null;
      _selectedWorkType = null;
      _selectedDateType = null;
      _selectedCity = null;
      _startTime = null;
      _endTime = null;
    });

    handleRefresh();
  }

  /// 修改所在地区
  handleChangeCity(value) {
    setState(() => _selectedCity = value);
    handleRefresh();
  }

  handleChangeWorkType(value) {
    setState(() => _selectedWorkType = value);
    handleRefresh();
  }

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(controlFinishLoad: true);
    _scrollController = ScrollController();
    initialResource();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    /// 展示骨架屏
    if (_isPageLoading) return SkeletonScreen(title: '作业信息', hasLeading: false);

    return DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
      child: EasyRefresh(
        onLoad: handleLoad,
        canLoadAfterNoMore: false,
        footer: EasyRefreshFooter(),
        controller: _easyRefreshController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text('作业信息'),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.w),
                child: Container(
                  height: 48.w,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SelectCity(
                        value: _selectedCity,
                        onSelected: handleChangeCity,
                      ),
                      WorkTypeDropdown(
                        value: _selectedWorkType,
                        onSelected: handleChangeWorkType,
                      ),
                      FilterButton(
                        selectedCropsType: _selectedCropsType,
                        selectedWorkType: _selectedWorkType,
                        selectedDateType: _selectedDateType,
                        selectedCity: _selectedCity,
                        startTime: _startTime,
                        endTime: _endTime,
                        onSubmit: handleSubmit,
                        onReset: handleReset,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: SliverHeaderDelegate.fixedExtent(
                extent: 100.w,
                child: Container(
                  color: Color(0xFFF2F2F2),
                  padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(25.w),
                          ),
                          child: Icon(utils.QmIcons.write, color: Colors.white),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '作业面积统计（亩）',
                          style: TextStyle(
                            fontSize: 17.w,
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            _resourceList
                                .fold<double>(0, (memo, item) => memo + item['area'])
                                .toStringAsFixed(2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.w,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList.separated(
              itemBuilder: (BuildContext context, int index) {
                return DriveWorkItem(workInfo: _resourceList[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10.w);
              },
              itemCount: _resourceList.length,
            ),
            FooterLocator.sliver(),
          ],
        ),
      ),
    );
  }
}
