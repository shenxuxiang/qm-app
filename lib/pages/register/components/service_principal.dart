import 'package:qm/utils/index.dart';
import 'package:qm/models/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qm/api/main.dart' as api;
import 'package:qm/entity/organization.dart';
import 'service_principal_modal_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServicePrincipal extends StatefulWidget {
  final String title;
  final Organization? value;
  final void Function(Organization value) onChanged;

  const ServicePrincipal({super.key, required this.title, required this.onChanged, this.value});

  @override
  State<ServicePrincipal> createState() => _ServicePrincipalState();
}

class _ServicePrincipalState extends State<ServicePrincipal> {
  /// 用户点击，打开 Sheet 弹框
  onTap(BuildContext context) async {
    MainModels mainModels = context.read<MainModels>();

    /// 如果服务主体为空，则发送请求获取服务主体
    if (mainModels.systemOrganization.isEmpty) {
      try {
        final response = await api.querySystemOrganization({});
        mainModels.setSystemOrganization(response.data);

        if (context.mounted) {
          handleOpenModal(context, mainModels.systemOrganization);
        }
      } on DioException {}
    } else {
      handleOpenModal(context, mainModels.systemOrganization);
    }
  }

  handleConfirm(VoidCallback onClosed) {
    return (List<Organization> value) {
      widget.onChanged(value.last);
      onClosed();
    };
  }

  handleOpenModal(BuildContext context, List<dynamic> organizationList) {
    showSheet(
      height: 600.w,
      context: context,
      builder: (BuildContext ctx, {required VoidCallback onClosed, Widget? child}) {
        return ServicePrincipalModalWidget(
          onConfirm: handleConfirm(onClosed),
          organizationList: organizationList,
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
                      widget.value?.organizationName ?? '请选择服务主体',
                      style: TextStyle(
                        height: 1,
                        fontSize: 13.sp,
                        color: widget.value != null ? Colors.black87 : Colors.black38,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(QmIcons.right, size: 18.w, color: Colors.black45),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
