import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkeletonScreen extends StatefulWidget {
  final String title;
  final bool? hasLeading;
  final Color? appBarColor;

  const SkeletonScreen({super.key, this.appBarColor, required this.title, this.hasLeading = true});

  @override
  State<SkeletonScreen> createState() => _SkeletonScreenState();
}

class _SkeletonScreenState extends State<SkeletonScreen> with SingleTickerProviderStateMixin {
  final Color _darkColor = Color(0xFFEFEFEF);
  AnimationController? _animationController;
  Animation<double>? _animation;
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer(Duration(milliseconds: 800), () {
      setState(() => _timer = null);
      _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
      _animation = CurvedAnimation(parent: _animationController!, curve: Curves.ease);
      _animationController?.repeat();
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  /// 返回上一页
  handleGoBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: widget.hasLeading!
            ? GestureDetector(onTap: handleGoBack, child: Icon(utils.QmIcons.back))
            : SizedBox(),
      ),
      body: _timer != null
          ? SizedBox()
          : Stack(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          height: 200.w,
                          decoration: BoxDecoration(
                            color: _darkColor,
                            borderRadius: BorderRadius.circular(6.w),
                          ),
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 230.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width: 230.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: _darkColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 230.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width: 230.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: _darkColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 230.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width: 230.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: _darkColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 230.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width: 230.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: _darkColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 230.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width: 230.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: _darkColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 230.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width: 230.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: _darkColor,
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                height: 85.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: _darkColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _animation!,
                  builder: (BuildContext context, Widget? child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.2, 0),
                          end: Alignment(1.2, 0),
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0xBBFFFFFF),
                            Color(0x00FFFFFF),
                          ],
                          stops: [
                            _animation!.value - 0.12,
                            _animation!.value,
                            _animation!.value + 0.12,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
