/// 渲染展示列表节点
part of 'index.dart';

class _RenderDisplayNode extends StatelessWidget {
  final String label;
  final Map<String, dynamic> value;
  final void Function(Map<String, dynamic> value) onTap;

  const _RenderDisplayNode({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}
