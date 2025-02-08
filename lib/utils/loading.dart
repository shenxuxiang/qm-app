import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Quaternion;

class Loading {
  static final _text = ''.obs;
  static bool _isClosed = true;

  static hide() {
    if (_isClosed) return;
    _isClosed = true;
    Get.back();
  }

  static show({
    String text = '努力加载中...',
    FractionalOffset offset = const FractionalOffset(0.5, 0.4),
  }) {
    _text.value = text;
    if (_isClosed) {
      _isClosed = false;
      Get.dialog(
        Obx(() => _LoadingWidget(text: _text.value, offset: offset)),
        barrierDismissible: false,
        barrierColor: Color(0x22000000),
        transitionDuration: const Duration(milliseconds: 200),
      );
    }
  }
}

class _LoadingWidget extends StatefulWidget {
  final String text;
  final FractionalOffset offset;

  const _LoadingWidget({
    super.key,
    required this.text,
    required this.offset,
  });

  @override
  State<_LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<_LoadingWidget> with SingleTickerProviderStateMixin {
  final double _width = 120.w;
  final double _height = 120.w;
  final double _loadingSize = 50.w;
  late final Animation<double> _animation;
  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.ease);
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    double screenWidth = size.width;
    double screenHeight = size.height;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned(
            width: _width,
            height: _height,
            left: (screenWidth - _width) * widget.offset.dx,
            top: (screenHeight - _height) * widget.offset.dy,
            child: MatrixTransition(
              animation: _animation,
              onTransform: (double value) {
                return Matrix4Tween(
                  begin: Matrix4.compose(
                    Vector3(0, -50, 0),
                    Quaternion.identity(),
                    Vector3(0.7, 0.7, 1),
                  ),
                  end: Matrix4.identity(),
                ).lerp(value);
              },
              child: Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    color: Color(0x66000000), borderRadius: BorderRadius.circular(8.w)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: _loadingSize,
                      height: _loadingSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(height: 20.w),
                    Text(
                      widget.text,
                      style: TextStyle(height: 1, fontSize: 14.w, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
