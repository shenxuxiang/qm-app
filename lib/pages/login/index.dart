import 'components/tab_one.dart';
import 'components/tab_two.dart';
import 'package:qm/common/base.dart';
import 'components/header_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends BasePage {
  const LoginPage({super.key, super.title});

  @override
  BasePageState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends BasePageState<LoginPage> with SingleTickerProviderStateMixin {
  int _activeKey = 0;
  late final TabController _tabController;

  _LoginPageState({super.author = false});

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _activeKey,
      animationDuration: Duration.zero,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void handleChangeActiveKey(int value) {
    _tabController.animateTo(value);
    setState(() {
      _activeKey = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil();
    return Material(
      child: Container(
        color: Color(0xffe8edfd),
        child: Stack(
          alignment: Alignment.topCenter,
          fit: StackFit.loose,
          children: [
            Positioned(
              top: 0,
              left: 0,
              width: screenUtil.screenWidth,
              height: 600.w,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.8,
                    stops: [0.9, 0.9],
                    center: FractionalOffset(0.5, 0.025),
                    colors: [Color(0xff476bf3), Colors.transparent],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 220.w,
                  child: Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    alignment: FractionalOffset(0.5, 0.5),
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0x22FFFFFF),
                        borderRadius: BorderRadius.circular(50.w),
                      ),
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0x66FFFFFF),
                          borderRadius: BorderRadius.circular(40.w),
                        ),
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xAAFFFFFF),
                            borderRadius: BorderRadius.circular(30.w),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            width: 40.w,
                            height: 40.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 340.w,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0x555b7ef1), offset: Offset(5, 10), blurRadius: 10),
                        BoxShadow(color: Color(0x555b7ef1), offset: Offset(-5, 10), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderTabs(
                          height: 60.w,
                          width: 340.w,
                          value: _activeKey,
                          onChanged: handleChangeActiveKey,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _tabController,
                              children: [
                                TabOne(),
                                TabTwo(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
