import 'package:get/get.dart';
import 'package:qmnj/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:qmnj/utils/index.dart' as utils;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabMine extends StatefulWidget {
  const TabMine({super.key});

  @override
  State<TabMine> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabMine> {
  final List<String> _operationList = [
    '当农机已到达作业地块并准备开始作业时，点击开始作业，并根据提示选择采集模式。',
    '如果没有终端设备，则直接选择本次作业对应的农作物、作业类型、作业幅宽、点击【确定】后即开始记录作业轨迹。',
    '如果有终端设备，则选择进入蓝牙设置界面进行设备配对连接，连接成功后选择本次作业对应的农作物、作业类型、作业幅宽，点击【确定】后即开始记录作业轨迹。',
    '农机作业完成后，点击【结束作业】。',
  ];

  final List<String> _tipList = [
    '为了保证采集数据的准确性，在开始作业前，请进入手机【设置】-【电池】设置页面，关闭省电模式，并允许农机助手 APP 自启动、关联启动、后台活动等。',
    '点击【开始作业】和【结束作业】时需要打开手机网络。',
  ];

  @override
  void initState() {
    super.initState();
  }

  handleViewInstruction() {
    utils.BottomSheet.show(
      height: 500.w,
      builder: (BuildContext context, {Widget? child, required Future<void> Function() onClose}) {
        final primaryColor = Theme.of(context).primaryColor;
        return Column(
          children: [
            SizedBox(
              height: 50.w,
              child: Center(
                child: Text(
                  '使用说明详情',
                  style: TextStyle(fontSize: 16.w, color: Colors.black),
                ),
              ),
            ),
            Container(height: 1, color: Colors.black12),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(9.w),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '操作说明',
                          style: TextStyle(
                            fontSize: 18.w,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ...[
                      for (String str in _operationList)
                        Padding(
                          padding: EdgeInsets.only(top: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.w,
                                margin: EdgeInsets.only(top: 6.w, left: 4.w),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(5.w),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  str,
                                  style: TextStyle(
                                    height: 1.5,
                                    fontSize: 14.w,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    SizedBox(height: 20.w),
                    Row(
                      children: [
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(9.w),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '提示',
                          style: TextStyle(
                            fontSize: 18.w,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ...[
                      for (String str in _tipList)
                        Padding(
                          padding: EdgeInsets.only(top: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10.w,
                                height: 10.w,
                                margin: EdgeInsets.only(top: 6.w, left: 4.w),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(5.w),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  str,
                                  style: TextStyle(
                                    height: 1.5,
                                    fontSize: 14.w,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 查看更新记录
  handleViewUpdateRecords() {
    utils.hapticFeedback();
    Get.toNamed('/update_records');
  }

  /// 检查更新
  handleCheckUpdate() {
    utils.hapticFeedback();
    utils.showAlertDialog(
      title: '提示',
      content: Text('已是最新版本'),
    );
  }

  /// 退出登录
  handleLogout() async {
    utils.hapticFeedback();
    final result = await utils.showAlertDialog(
      title: '提示',
      content: Text('是否确认退出登录？'),
    );

    if (result ?? false) {
      await api.queryUserLogout();
      await utils.storage.remove('User-Token');
      await utils.storage.remove('User-Info');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainModels = Get.find<MainModels>();
    final primaryColor = Theme.of(context).primaryColor;

    debugPrint('mainModels.userInfo: ${mainModels.userInfo}');
    return Stack(
      children: [
        /// 背景
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 2,
              stops: [0.8, 0.8, 0.8],
              center: FractionalOffset(0.5, -0.5),
              colors: [primaryColor, primaryColor, Color(0xFFE9E9E9)],
            ),
          ),
        ),

        /// 内容
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 16.5.w),
              Align(
                child: Text(
                  '个人中心',
                  style: TextStyle(fontSize: 20.w, color: Colors.white, height: 1),
                ),
              ),
              SizedBox(height: 20.w),
              SizedBox(
                width: double.infinity,
                height: 165.w,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 300.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Color(0x11000000), offset: Offset(5, 5), blurRadius: 10)
                        ],
                      ),
                      child: Obx(
                        () => Column(
                          children: [
                            SizedBox(height: 50.w),
                            Text(
                              mainModels.userInfo['realName'],
                              style: TextStyle(
                                fontSize: 16.w,
                                color: Colors.black87,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.w),
                            Text(
                              mainModels.userInfo['idNumber'],
                              style: TextStyle(
                                fontSize: 14.w,
                                color: Colors.black54,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45.w),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(40.w),
                          ),
                          child: Icon(utils.QmIcons.mineFill, color: Colors.white, size: 55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 300.w,
                height: 260.w,
                margin: EdgeInsets.only(top: 40.w, left: 30.w, right: 30.w),
                padding: EdgeInsets.only(top: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.w),
                  boxShadow: [
                    BoxShadow(color: Color(0x11000000), offset: Offset(5, 5), blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 4.w, height: 20.w, color: primaryColor),
                        SizedBox(width: 8.w),
                        Text('设置', style: TextStyle(color: Colors.black87, fontSize: 16.w)),
                      ],
                    ),
                    SizedBox(height: 20.w),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: GestureDetector(
                        onTap: handleViewInstruction,
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.only(right: 8.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              child: Icon(utils.QmIcons.book, color: Colors.white, size: 24.w),
                            ),
                            Expanded(
                              child: Text(
                                '使用说明',
                                style: TextStyle(fontSize: 14.w, color: Colors.black87),
                              ),
                            ),
                            Icon(utils.QmIcons.right, color: Colors.black54, size: 20.w),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 10.w),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: GestureDetector(
                        onTap: handleViewUpdateRecords,
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.only(right: 8.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF0099FF),
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              child: Icon(utils.QmIcons.setting, color: Colors.white, size: 24.w),
                            ),
                            Expanded(
                              child: Text(
                                '更新记录',
                                style: TextStyle(fontSize: 14.w, color: Colors.black87),
                              ),
                            ),
                            Icon(utils.QmIcons.right, color: Colors.black54, size: 20.w),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 10.w),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: GestureDetector(
                        onTap: handleCheckUpdate,
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.only(right: 8.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF9933),
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              child: Icon(utils.QmIcons.defense, color: Colors.white, size: 24.w),
                            ),
                            Expanded(
                              child: Text(
                                '检查更新',
                                style: TextStyle(fontSize: 14.w, color: Colors.black87),
                              ),
                            ),
                            Icon(utils.QmIcons.right, color: Colors.black54, size: 20.w),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.black12,
                      margin: EdgeInsets.symmetric(vertical: 10.w),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: GestureDetector(
                        onTap: handleLogout,
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              margin: EdgeInsets.only(right: 8.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF4949),
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              child: Icon(utils.QmIcons.mineFill, color: Colors.white, size: 24.w),
                            ),
                            Expanded(
                              child: Text(
                                '推出登录',
                                style: TextStyle(fontSize: 14.w, color: Colors.black87),
                              ),
                            ),
                            Icon(utils.QmIcons.right, color: Colors.black54, size: 20.w),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
