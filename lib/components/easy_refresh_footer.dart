import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EasyRefreshFooter extends Footer {
  const EasyRefreshFooter({
    super.clamping = false,
    super.triggerOffset = 60,
    super.position = IndicatorPosition.locator,
  });

  _renderFooter(IndicatorResult result, IndicatorMode mode) {
    if (result != IndicatorResult.noMore) {
      if (mode == IndicatorMode.processing) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFC9C9C9)),
            strokeCap: StrokeCap.round,
            strokeWidth: 3.w,
          ),
        );
      } else {
        return createTextTemplate('上拉加载更多～');
      }
    } else {
      return createTextTemplate('没有更多数据了～');
    }
  }

  createTextTemplate(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 12.w, color: Colors.black54, height: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: _renderFooter(state.result, state.mode),
    );
  }
}
