import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_dimens.dart';
import 'shimmer_box.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.semanticLabel,
  });

  final String url;

  final double? width;

  final double? height;

  final BoxFit fit;

  final BorderRadius? borderRadius;

  final Color? backgroundColor;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool hasUrl = url.trim().isNotEmpty;

    Widget content = hasUrl
        ? CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            placeholder: (BuildContext context, String _) =>
                _placeholder(context),
            errorWidget: (BuildContext context, String _, Object _) =>
                _error(context),
          )
        : _error(context);

    if (backgroundColor != null) {
      content = ColoredBox(color: backgroundColor!, child: content);
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox(width: width, height: height, child: content),
    );
  }

  Widget _placeholder(BuildContext context) => ShimmerBox.animated(
    width: width,
    height: height,
    borderRadius: borderRadius ?? AppDimens.brCard,
  );

  Widget _error(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainerLow,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Symbols.image_not_supported,
        color: scheme.onSurfaceVariant,
        size: AppDimens.s32,
      ),
    );
  }
}
