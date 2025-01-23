import 'package:flutter/material.dart';

typedef SliverHeaderDelegateBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;

  final SliverHeaderDelegateBuilder builder;

  SliverHeaderDelegate({this.minExtent = 0, required this.maxExtent, required Widget child})
      : builder = ((ctx, offset, overlap) => child);

  SliverHeaderDelegate.fixedExtent({required double extent, required Widget child})
      : maxExtent = extent,
        minExtent = extent,
        builder = ((ctx, offset, overlap) => child);

  SliverHeaderDelegate.builder({
    this.minExtent = 0,
    required this.builder,
    required this.maxExtent,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: builder(context, shrinkOffset, overlapsContent));
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
  }
}
