import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:qmnj/global_vars.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:qmnj/common/base_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:qmnj/components/skeleton_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocation extends BasePage {
  const UserLocation({super.key, super.title});

  @override
  BasePageState<UserLocation> createState() => _UserLocationState();
}

class _UserLocationState extends BasePageState<UserLocation> {
  List<dynamic> positions = [];

  @override
  initState() {
    positions = utils.storage.getItem('User-Driver-Work-Trace') ?? [];

    super.initState();
  }

  handleGoBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户定位'),
        leading: GestureDetector(onTap: handleGoBack, child: Icon(utils.QmIcons.back)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: [
            for (final item in positions)
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
                      '${item['createTime']}：',
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
                          '${item['longitude']}, ${item['latitude']}',
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
    );
  }
}
