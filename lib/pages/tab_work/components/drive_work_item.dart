import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final workTypeBadgeColor = {
  '1': Color(0xFF0066FF),
  '2': Color(0xFFFF4949),
  '3': Color(0xFFFF9933),
  '4': Color(0xFF6666FF),
  '5': Color(0xFF336699),
  '8017467609526051994': Color(0xFF339966),
  '8017472454249163843': Color(0xFF669999),
};

final cropsTypeBadgeColor = {
  '8': Color(0xFF0066FF),
  '9': Color(0xFFFF3333),
};

class DriveWorkItem extends StatelessWidget {
  final Map<String, dynamic> workInfo;

  const DriveWorkItem({super.key, required this.workInfo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/work_detail', arguments: workInfo['workId']);
      },
      child: Container(
        height: 110.w,
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 70.w),
                      Text(
                        '${workInfo['area'].toStringAsFixed(2)} 亩',
                        style: TextStyle(fontSize: 16.w, color: Colors.black87, height: 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.w),
                  Text(
                    workInfo['regionName'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.w, color: Colors.black54, height: 1),
                  ),
                  SizedBox(height: 20.w),
                  Text(
                    '${workInfo['workEndTime']}',
                    style: TextStyle(fontSize: 14.w, color: Colors.black54, height: 1),
                  )
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 70.w,
                height: 30.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.w),
                    bottomRight: Radius.circular(8.w),
                  ),
                  color: workTypeBadgeColor['${workInfo['workTypeId']}'],
                ),
                child: Text('${workInfo['workType']}',
                    style: TextStyle(color: Colors.white, fontSize: 12.w, height: 1)),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 40.w,
                height: 26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.w),
                    bottomLeft: Radius.circular(8.w),
                  ),
                  color: cropsTypeBadgeColor['${workInfo['workSeason']}'],
                ),
                child: Text(
                  '${workInfo['workSeasonDesc']}',
                  style: TextStyle(
                    height: 1,
                    fontSize: 13.w,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
