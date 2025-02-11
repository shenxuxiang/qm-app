import 'package:get/get.dart';
import 'package:qmnj/models/main.dart';
import 'package:flutter/material.dart';
import 'package:qmnj/api/main.dart' as api;
import 'package:qmnj/utils/index.dart' as utils;
import 'package:qmnj/components/cascader/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServicePrincipal extends StatefulWidget {
  final String title;
  final SelectedTreeNode? value;
  final void Function(SelectedTreeNode value) onChanged;

  const ServicePrincipal({super.key, required this.title, required this.onChanged, this.value});

  @override
  State<ServicePrincipal> createState() => _ServicePrincipalState();
}

class _ServicePrincipalState extends State<ServicePrincipal> {
  /// 用户点击，打开 Sheet 弹框
  onTap(BuildContext context) async {
    final mainModels = Get.find<MainModels>();

    /// 如果服务主体为空，则发送请求获取服务主体
    if (mainModels.systemOrganization.isEmpty) {
      try {
        final response = await api.querySystemOrganization({});
        mainModels.setSystemOrganization(response.data);

        if (context.mounted) {
          handleOpenModal(mainModels.systemOrganization);
        }
      } on utils.DioException {}
    } else {
      handleOpenModal(mainModels.systemOrganization);
    }
  }

  handleOpenModal(List<dynamic> organizationList) {
    utils.BottomSheet.show(
      height: 600.w,
      builder: (BuildContext context, {Widget? child, required VoidCallback onClose}) {
        return CasCadeWidget(
          valueKey: 'organizationId',
          placeholder: '请选择服务主体',
          labelKey: 'organizationName',
          sourceList: organizationList,
          onConfirm: (List<SelectedTreeNode> value) {
            widget.onChanged(value.last);
            onClose();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.sp,
              height: 1,
              // fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(context),
            child: Container(
              height: 42.w,
              width: double.infinity,
              padding: EdgeInsets.only(left: 0, right: 0, top: 16.w, bottom: 12.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffdddddd), width: 1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      widget.value?.label ?? '请选择服务主体',
                      style: TextStyle(
                        height: 1,
                        fontSize: 13.sp,
                        color: widget.value != null ? Colors.black87 : Colors.black38,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(utils.QmIcons.right, size: 18.w, color: Colors.black45),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
