import 'dart:async';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:qm/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:qm/entity/organization.dart';
import 'package:qm/components/qm_input.dart';
import 'package:qm/components/button_widget.dart';
import 'package:qm/components/sticky_positioned.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServicePrincipalModalWidget extends StatefulWidget {
  final List<dynamic> organizationList;
  final void Function(List<Organization> value) onConfirm;

  const ServicePrincipalModalWidget({
    super.key,
    required this.onConfirm,
    required this.organizationList,
  });

  @override
  State<ServicePrincipalModalWidget> createState() => _ServicePrincipalModalWidgetState();
}

class _ServicePrincipalModalWidgetState extends State<ServicePrincipalModalWidget> {
  /// 定时器
  Timer? _timer;

  /// 搜索条件
  String _searchCondition = '';

  /// 当前展示高亮的首字母
  String _activeFirstLetter = '';

  /// 搜索结果列表
  List<dynamic> _searchResultList = [];

  /// 选中项
  List<Organization> _selectedList = [];

  /// 表示当前是用户点击首字母
  bool _isUserClickFirstLetter = false;

  /// 展示列表
  Map<String, List<dynamic>> _displayList = {};

  late final ScrollController _scrollController;

  /// 收集每个 displayListItem 滚动偏移量集合
  final Map<String, double> _displayListItemOffsets = {};

  /// 修改展示列表
  void handleChangeDisplayList(List<dynamic> list) {
    List<dynamic> organizationList = List.of(list);
    organizationList.sort((a, b) => a['firstLetter'].compareTo(b['firstLetter']));

    Map<String, List<dynamic>> maps = {};
    String firstLetter = '';
    for (final item in list) {
      firstLetter = item['firstLetter'];
      maps[firstLetter] ??= [];
      maps[firstLetter]!.add(item);
    }
    setState(() {
      _displayListItemOffsets.clear();
      _displayList = maps;
    });
  }

  /// 删除选中项
  deleteSelectedEntry(Organization organization) {
    return () {
      int start = _selectedList.indexOf(organization);
      if (start < 0) return;

      List<Organization> selectedList = List.of(_selectedList);

      /// 如果 organization.children 为空，则说明该选项是一个叶子节点。
      /// 所以该选项就是最后一个选项，删除该选项不需要更新展示列表（disPlayList）。
      /// 否则，就需要更新展示列表。
      if (organization.children.isEmpty) {
        selectedList.removeAt(start);
      } else {
        selectedList.removeRange(start, selectedList.length);

        /// disPlayList 始终取它的父级的 children。如果 selectedList 为空，则初始化展示列表。
        List<dynamic> displayList =
            selectedList.isEmpty ? widget.organizationList : selectedList.last.children;

        /// 每次修改展示列表时都需要将滚动到顶部，否则粘性定位可能会出现异常。
        _scrollController.position.jumpTo(0);
        handleChangeDisplayList(displayList);
      }

      setState(() {
        _selectedList = selectedList;
      });
    };
  }

  /// 选中
  handleSelectedItem(dynamic item) {
    setState(() {
      if (_selectedList.isEmpty || _selectedList.last.children.isNotEmpty) {
        _selectedList.add(Organization.fromJson(item));
      } else {
        _selectedList.last = Organization.fromJson(item);
      }
    });

    if (item['children']?.isNotEmpty ?? false) {
      handleChangeDisplayList(item['children']);
    }
  }

  /// StickyPositionedItem（粘性定位） 挂载成功的回调
  void handleStickyPositionedItemMounted(String title, double offset) {
    _displayListItemOffsets.addEntries([MapEntry(title, offset)]);
  }

  /// 修改搜索条件
  void handleChangeSearchCondition(String value) {
    List<dynamic> resultList = [];
    if (value.isNotEmpty) {
      for (final entry in _displayList.entries) {
        for (final item in entry.value) {
          if (item['organizationName'].contains(value)) {
            resultList.add(item);
          }
        }
      }
    }

    setState(() {
      _searchCondition = value;
      _searchResultList = resultList;
    });
  }

  /// 点击确认按钮
  void handleConfirm() {
    if (_selectedList.isEmpty) {
      Toast.show('请选择服务主体');
      return;
    }
    widget.onConfirm(_selectedList);
  }

  /// 用户点击首字符
  handleTapFirstLetter(String key) {
    _timer?.cancel();
    _isUserClickFirstLetter = true;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    double offset = _displayListItemOffsets[key]!.clamp(0, maxScrollExtent);
    _scrollController.jumpTo(offset);
    setState(() {
      _activeFirstLetter = key;
    });
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (Timer timer) {
        timer.cancel();
        _isUserClickFirstLetter = false;
      },
    );
  }

  /// 监听滚动
  handleScroll() {
    /// 如果是用户点击了首字符，则不触发滚动监听。
    if (_isUserClickFirstLetter) return;
    final pixels = _scrollController.position.pixels;
    String key = '';
    for (final entry in _displayListItemOffsets.entries) {
      if (pixels >= entry.value) {
        key = entry.key;
      } else {
        break;
      }
    }

    setState(() => _activeFirstLetter = key);
  }

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0);
    _scrollController.addListener(handleScroll);
    handleChangeDisplayList(widget.organizationList);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: [
          Container(
            color: Color(0xFFF9F9F9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 50.w,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: QmInput(
                          allowClear: true,
                          value: _searchCondition,
                          placeholder: '搜索服务主体',
                          textInputAction: TextInputAction.done,
                          onChanged: handleChangeSearchCondition,
                          prefix: Icon(QmIcons.search, size: 16.w, color: Colors.black38),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ButtonWidget(onPressed: handleConfirm, text: '确定', height: 40.w, width: 60.w),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minHeight: 54.w, minWidth: double.infinity),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 12.w,
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.center,
                    children: _selectedList.isEmpty
                        ? [
                            Text(
                              '请选择服务主体',
                              style: TextStyle(color: Colors.black38, fontSize: 16.sp, height: 1),
                            ),
                          ]
                        : [
                            for (final item in _selectedList)
                              selectedItemWidget(item.organizationName, deleteSelectedEntry(item))
                          ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        for (final entry in _displayList.entries)
                          _StickyPositionedItem(
                            title: entry.key,
                            list: entry.value,
                            onSelected: handleSelectedItem,
                            onMounted: handleStickyPositionedItemMounted,
                            key: Key(entry.key + _displayList.entries.toString()),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 右侧边缘展示首字母
          Positioned(
            top: 62.w,
            right: 0.w,
            width: 40.w,
            height: constraints.maxHeight - 80.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final key in _displayList.keys)
                  GestureDetector(
                    onTap: () => handleTapFirstLetter(key),
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        color: _activeFirstLetter == key ? Colors.green : Colors.transparent,
                      ),
                      child: Text(
                        key.toUpperCase(),
                        style: TextStyle(
                          height: 1,
                          fontSize: 12.w,
                          color: _activeFirstLetter == key ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// 展示搜索结果
          _searchCondition.isNotEmpty
              ? Positioned(
                  left: 0,
                  top: 50.w,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight - 50.w,
                  child: Container(
                    color: Color(0xFFF9F9F9),
                    constraints: BoxConstraints.expand(),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: SingleChildScrollView(
                      child: Column(
                        children: _searchResultList.isEmpty
                            ? [
                                Padding(padding: EdgeInsets.only(top: 10.w)),
                                Text(
                                  '没有搜索到结果～',
                                  style: TextStyle(
                                    height: 2,
                                    fontSize: 15.w,
                                    color: Colors.black54,
                                  ),
                                )
                              ]
                            : [
                                for (final item in _searchResultList)
                                  _displayItemWidget(
                                    value: item,
                                    label: item['organizationName'],
                                    onTap: (Map<String, dynamic> value) {
                                      widget.onConfirm([Organization.fromJson(value)]);
                                    },
                                  )
                              ],
                      ),
                    ),
                  ),
                )
              : Padding(padding: EdgeInsets.zero),
        ],
      );
    });
  }
}

/// 选中展示项
Widget selectedItemWidget(String label, VoidCallback onPressed) {
  return SizedBox(
    height: 32.w,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: Icon(Icons.close, color: Colors.white),
      label: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1),
      ),
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(0),
        minimumSize: WidgetStateProperty.all(Size(0, 32.w)),
        maximumSize: WidgetStateProperty.all(Size(double.infinity, 32.w)),
        backgroundColor: WidgetStateProperty.all(Theme.of(GlobalVars.context).primaryColor),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 0, horizontal: 12.w)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.w)),
        ),
      ),
    ),
  );
}

/// 展示项
Widget _displayItemWidget({
  required String label,
  required Map<String, dynamic> value,
  required void Function(Map<String, dynamic> value) onTap,
}) {
  return ElevatedButton(
    style: ButtonStyle(
      alignment: Alignment.centerLeft,
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(RoundedRectangleBorder()),
      backgroundColor: WidgetStateProperty.all(Color(0xFFF9F9F9)),
      padding: WidgetStateProperty.all(EdgeInsets.only(left: 10.w)),
      maximumSize: WidgetStateProperty.all(Size(double.infinity, 50.w)),
      minimumSize: WidgetStateProperty.all(Size(double.infinity, 50.w)),
    ),
    onPressed: () => onTap(value),
    child: Text(
      label,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16.sp, color: Color(0xFF333333)),
    ),
  );
}

/// 粘性定位展示项
class _StickyPositionedItem extends StatefulWidget {
  final String title;
  final List<dynamic> list;
  final void Function(dynamic value) onSelected;
  final void Function(String title, double offset) onMounted;

  const _StickyPositionedItem({
    super.key,
    required this.list,
    required this.title,
    required this.onMounted,
    required this.onSelected,
  });

  @override
  _StickyPositionedItemState createState() => _StickyPositionedItemState();
}

class _StickyPositionedItemState extends State<_StickyPositionedItem> {
  mountedCallback(BuildContext context) {
    return (Duration _) {
      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox;
        final ancestor = Scrollable.of(context).notificationContext!.findRenderObject();
        Offset offset = box.localToGlobal(Offset.zero, ancestor: ancestor);
        widget.onMounted(widget.title, offset.dy.abs());
      }
    };
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(mountedCallback(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StickyPositioned(
      header: Container(
        height: 34.w,
        color: const Color(0xFFE9E9E9),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          widget.title.toUpperCase(),
          style: TextStyle(
            height: 1,
            fontSize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in widget.list)
            _displayItemWidget(
              value: item,
              onTap: widget.onSelected,
              label: item['organizationName'],
            )
        ],
      ),
    );
  }
}
