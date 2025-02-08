/// 渲染选中项节点
part of 'index.dart';

class _RenderSelectedNode extends StatelessWidget {
  final SelectedTreeNode value;
  final void Function(SelectedTreeNode value) onPressed;

  const _RenderSelectedNode({super.key, required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.w,
      child: ElevatedButton.icon(
        onPressed: () => onPressed(value),
        iconAlignment: IconAlignment.end,
        icon: Icon(Icons.close, color: Colors.white),
        label: Text(
          value.label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1),
        ),
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(Size(0, 32.w)),
          maximumSize: WidgetStateProperty.all(Size(double.infinity, 32.w)),
          backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
          padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 0, horizontal: 12.w)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.w)),
          ),
        ),
      ),
    );
  }
}
