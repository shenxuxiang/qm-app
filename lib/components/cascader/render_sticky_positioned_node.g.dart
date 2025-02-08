/// 渲染粘性定位节点
part of 'index.dart';

/// 粘性定位展示项
class _StickyPositionedItem extends StatefulWidget {
  final String labelKey;
  final String firstLetter;
  final List<dynamic> list;
  final void Function(Map<String, dynamic> value) onSelected;
  final void Function(String title, double offset) onMounted;

  const _StickyPositionedItem({
    super.key,
    required this.list,
    required this.labelKey,
    required this.onMounted,
    required this.onSelected,
    required this.firstLetter,
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
        widget.onMounted(widget.firstLetter, offset.dy.abs());
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
          widget.firstLetter.toUpperCase(),
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
            _RenderDisplayNode(
              value: item,
              onTap: widget.onSelected,
              label: item[widget.labelKey],
            )
        ],
      ),
    );
  }
}
