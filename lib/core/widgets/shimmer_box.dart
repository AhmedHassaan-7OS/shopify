import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_dimens.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  static Color baseColorOf(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLow;

  static Color highlightColorOf(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLowest;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColorOf(context),
      highlightColor: highlightColorOf(context),
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppDimens.brInput,
    this.shape,
    this.animate = false,
  });

  const ShimmerBox.animated({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppDimens.brInput,
    this.shape,
  }) : animate = true;

  factory ShimmerBox.circle({Key? key, required double size}) => ShimmerBox(
    key: key,
    width: size,
    height: size,
    shape: BoxShape.circle,
    borderRadius: null,
  );

  final double? width;

  final double? height;

  final BorderRadius? borderRadius;

  final BoxShape? shape;

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final BoxShape effectiveShape = shape ?? BoxShape.rectangle;
    final Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppShimmer.baseColorOf(context),
        shape: effectiveShape,
        borderRadius: effectiveShape == BoxShape.circle ? null : borderRadius,
      ),
    );

    return animate ? AppShimmer(child: box) : box;
  }
}
