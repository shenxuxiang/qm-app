import 'dart:async';
import 'package:lpinyin/lpinyin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qmnj/components/qm_input.dart';
import 'package:qmnj/utils/index.dart' as utils;
import 'package:qmnj/components/empty_widget.dart';
import 'package:qmnj/components/button_widget.dart';
import 'package:qmnj/components/sticky_positioned.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part 'render_display_node.g.dart';

part 'render_selected_node.g.dart';

part 'render_sticky_positioned_node.g.dart';

class SelectedTreeNode {
  final String value;
  final String label;
  final List<dynamic>? children;

  const SelectedTreeNode({required this.value, required this.label, this.children});

  factory SelectedTreeNode.fromJson(Map<String, dynamic> json) => SelectedTreeNode(
        value: json['value'],
        label: json['label'],
        children: json['children'],
      );
}

class CasCadeWidget extends StatefulWidget {
  final String labelKey;
  final String valueKey;
  final String childrenKey;
  final String placeholder;
  final List<dynamic> sourceList;
  final void Function(List<SelectedTreeNode> value) onConfirm;

  const CasCadeWidget({
    super.key,
    this.labelKey = 'label',
    this.valueKey = 'value',
    required this.onConfirm,
    required this.sourceList,
    this.childrenKey = 'children',
    this.placeholder = '请选择您想要的内容',
  });

  @override
  State<CasCadeWidget> createState() => _CasCadeWidgetState();
}

class _CasCadeWidgetState extends State<CasCadeWidget> {
  /// 定时器
  Timer? _timer;

  /// 搜索条件
  String _searchCondition = '';

  /// 当前展示高亮的首字母
  String _activeFirstLetter = '';

  /// 搜索结果列表
  List<dynamic> _searchResultList = [];

  /// 选中项
  List<SelectedTreeNode> _selectedList = [];

  /// 表示当前是用户点击首字母
  bool _isUserClickFirstLetter = false;

  /// 展示列表
  Map<String, List<dynamic>> _displayList = {};

  late final ScrollController _scrollController;

  /// 收集每个 displayListItem 滚动偏移量集合
  final Map<String, double> _displayListItemOffsets = {};

  /// 修改展示列表
  void handleChangeDisplayList(List<dynamic> list) {
    list = List.of(list);

    /// 更具名称的首字母进行升序排列
    list.sort((prev, next) {
      return PinyinHelper.getFirstWordPinyin(prev[widget.labelKey])
          .compareTo(PinyinHelper.getFirstWordPinyin(next[widget.labelKey]));
    });

    Map<String, List<dynamic>> maps = {};
    String firstLetter = '';
    for (final item in list) {
      firstLetter = PinyinHelper.getFirstWordPinyin(item[widget.labelKey]).substring(0, 1);
      maps[firstLetter] ??= [];
      maps[firstLetter]!.add(item);
    }

    if (_scrollController.positions.isNotEmpty) {
      _scrollController.position.jumpTo(0);
    }

    setState(() {
      _displayList = maps;
      _displayListItemOffsets.clear();
    });
  }

  /// 删除选中项
  void deleteSelectedEntry(SelectedTreeNode deleteItem) {
    int start = _selectedList.indexOf(deleteItem);
    if (start < 0) return;

    List<SelectedTreeNode> newList = List.of(_selectedList);

    /// 如果 organization.children 为空，则说明该选项是一个叶子节点。
    /// 所以该选项就是最后一个选项，删除该选项不需要更新展示列表（disPlayList）。
    /// 否则，就需要更新展示列表。
    if (_selectedList.last == deleteItem && (deleteItem.children?.isEmpty ?? true)) {
      newList.removeLast();
    } else {
      newList.removeRange(start, newList.length);

      /// 每次修改展示列表时都需要将滚动到顶部，否则粘性定位可能会出现异常。
      _scrollController.position.jumpTo(0);

      /// 更新展示列表
      /// disPlayList 始终取它的父级的 children。如果 selectedList 为空，则展示内容为初始化时的列表。
      handleChangeDisplayList(newList.isEmpty ? widget.sourceList : newList.last.children!);
    }

    setState(() => _selectedList = newList);
  }

  /// 修改选中项
  handleSelectedItem(Map<String, dynamic> selectedItem) {
    SelectedTreeNode node = SelectedTreeNode(
      value: selectedItem[widget.valueKey],
      label: selectedItem[widget.labelKey],
      children: selectedItem[widget.childrenKey],
    );
    setState(() {
      if (_selectedList.isEmpty || (_selectedList.last.children?.isNotEmpty ?? false)) {
        _selectedList.add(node);
      } else {
        _selectedList.last = node;
      }
    });

    if (node.children?.isNotEmpty ?? false) handleChangeDisplayList(node.children!);
  }

  /// StickyPositionedItem（粘性定位） 挂载成功的回调
  void handleStickyPositionedItemMounted(String firstLetter, double offset) {
    _displayListItemOffsets.addEntries([MapEntry(firstLetter, offset)]);
  }

  /// 修改搜索条件索出结果，并展示。
  void handleChangeSearchCondition(String value) {
    List<dynamic> resultList = [];
    if (value.isNotEmpty) {
      for (final nodeList in _displayList.values) {
        for (final node in nodeList) {
          if (node[widget.labelKey].contains(value)) {
            resultList.add(node);
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
      utils.Toast.show('请选择服务主体');
      return;
    }
    widget.onConfirm(_selectedList);
  }

  /// 用户点击右侧竖排的首字符，展示列表将滚动到对应的位置。
  handleTapFirstLetter(String firstLetter) {
    _timer?.cancel();
    _isUserClickFirstLetter = true;
    setState(() => _activeFirstLetter = firstLetter);
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo(_displayListItemOffsets[firstLetter]!.clamp(0, maxScrollExtent));

    /// 添加一个定时任务， 100ms 后执行
    _timer = Timer(
      const Duration(milliseconds: 100),
      () => _isUserClickFirstLetter = false,
    );
  }

  /// 监听用户的滚动行为
  void handleScroll() {
    /// _isUserClickFirstLetter == true 表示该滚动行为是用户点击了首字符后触发的滚动。
    /// 不应该对此行为进行监听。
    if (_isUserClickFirstLetter) return;
    final pixels = _scrollController.position.pixels;
    String firstLetter = '';
    for (final entry in _displayListItemOffsets.entries) {
      if (pixels >= entry.value) {
        firstLetter = entry.key;
      } else {
        break;
      }
    }

    setState(() => _activeFirstLetter = firstLetter);
  }

  @override
  void initState() {
    _scrollController = ScrollController(initialScrollOffset: 0);
    final onScroll = utils.throttle<VoidCallback>(handleScroll, Duration(milliseconds: 200));
    _scrollController.addListener(onScroll);

    /// 组件在初始化时，应该初始化展示列表，根据传入的 sourceList 对其按照搜字母进行排序，
    /// 并找出所有的首字母，将其排列在右侧。
    handleChangeDisplayList(widget.sourceList);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(handleScroll);
    _scrollController.dispose();
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
                /// 搜索框
                Container(
                  height: 50.w,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: QmInput(
                          allowClear: true,
                          value: _searchCondition,
                          placeholder: '请输入您要搜索的内容',
                          textInputAction: TextInputAction.done,
                          onChanged: handleChangeSearchCondition,
                          prefix: Icon(utils.QmIcons.search, size: 16.w, color: Colors.black38),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ButtonWidget(onPressed: handleConfirm, text: '确定', height: 40.w, width: 60.w),
                    ],
                  ),
                ),

                /// 展示选中的内容
                Container(
                  constraints: BoxConstraints(minHeight: 54.w, minWidth: double.infinity),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 12.w,
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    children: _selectedList.isEmpty
                        ? [
                            Text(
                              widget.placeholder,
                              style: TextStyle(color: Colors.black54, fontSize: 15.w, height: 1),
                            ),
                          ]
                        : [
                            for (final item in _selectedList)
                              _RenderSelectedNode(
                                value: item,
                                onPressed: deleteSelectedEntry,
                              )
                          ],
                  ),
                ),

                /// 展示列表
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: _displayList.isNotEmpty
                        ? Column(
                            children: [
                              for (final entry in _displayList.entries)
                                _StickyPositionedItem(
                                  list: entry.value,
                                  firstLetter: entry.key,
                                  labelKey: widget.labelKey,
                                  onSelected: handleSelectedItem,
                                  onMounted: handleStickyPositionedItemMounted,
                                  key: Key(entry.key + _displayList.entries.toString()),
                                )
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 100.w,
                            child: EmptyWidget(),
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
                for (final firstLetter in _displayList.keys)
                  GestureDetector(
                    onTap: () => handleTapFirstLetter(firstLetter),
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        color:
                            _activeFirstLetter == firstLetter ? Colors.green : Colors.transparent,
                      ),
                      child: Text(
                        firstLetter.toUpperCase(),
                        style: TextStyle(
                          height: 1,
                          fontSize: 12.w,
                          color: _activeFirstLetter == firstLetter ? Colors.white : Colors.black,
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
                                  _RenderDisplayNode(
                                    value: item,
                                    label: item[widget.labelKey],
                                    onTap: (Map<String, dynamic> value) {
                                      widget.onConfirm([
                                        SelectedTreeNode(
                                          value: value[widget.valueKey],
                                          label: value[widget.labelKey],
                                          children: value[widget.childrenKey],
                                        )
                                      ]);
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
