import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:qmnj/common/base_page.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:qmnj/components/skeleton_screen.dart';
import 'package:qmnj/components/expansion_panel.dart';
import 'package:qmnj/components/easy_refresh_footer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateRecords extends BasePage {
  const UpdateRecords({super.key, super.title});

  @override
  BasePageState<UpdateRecords> createState() => _UpdateRecordsState();
}

class _UpdateRecordsState extends BasePageState<UpdateRecords> {
  int _pageNum = 1;
  final _pageSize = 30;
  bool _noMore = false;
  bool _isPageLoading = true;
  List<dynamic> _resourceList = [];
  late final EasyRefreshController _easyRefreshController;

  /// 返回上一页
  handleGoBack() {
    Get.back();
  }

  Future initialResource() async {
    try {
      _pageNum = 1;
      final resp = await api.queryAppVersions({'pageNum': _pageNum, 'pageSize': _pageSize});
      setState(() {
        _resourceList = resp.data['list'];
        _noMore = _resourceList.length >= resp.data['total'];
      });

      IndicatorResult result = _noMore ? IndicatorResult.noMore : IndicatorResult.success;
      _easyRefreshController.finishLoad(result);
    } catch (error) {
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }

    setState(() => _isPageLoading = false);
  }

  handleLoad() async {
    try {
      final resp = await api.queryAppVersions({'pageNum': _pageNum + 1, 'pageSize': _pageSize});
      setState(() {
        _pageNum += 1;
        _resourceList.addAll(resp.data['list'] ?? []);
        _noMore = _resourceList.length >= resp.data['total'];
        IndicatorResult result = _noMore ? IndicatorResult.noMore : IndicatorResult.success;
        _easyRefreshController.finishLoad(result);
      });
    } catch (error) {
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }
  }

  @override
  void initState() {
    _easyRefreshController = EasyRefreshController(controlFinishLoad: true);
    initialResource();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPageLoading) return SkeletonScreen(title: '更新记录');

    return Material(
      color: Colors.white,
      child: EasyRefresh(
        onLoad: handleLoad,
        canLoadAfterNoMore: false,
        controller: _easyRefreshController,
        footer: EasyRefreshFooter(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              title: Text('更新记录'),
              leading: GestureDetector(
                onTap: handleGoBack,
                child: Icon(utils.QmIcons.back),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: IconThemeData(color: Colors.white, size: 22.w),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.w),
            ),
            SliverList.builder(
              itemCount: _resourceList.length,
              itemBuilder: (BuildContext context, int index) {
                return ExpansionPanelWidget(
                  header: Text(_resourceList[index]['version']),
                  body: Text(_resourceList[index]['content']),
                  bodyPadding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 8.w),
                );
              },
            ),
            FooterLocator.sliver(),
          ],
        ),
      ),
    );
  }
}
