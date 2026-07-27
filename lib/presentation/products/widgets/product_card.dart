import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  static const int titleMaxLines = 2;
  static const double wideTitleWidth = 200.0;
  static const double _ratingBadgeExtent = 24.0;

  final ProductModel product;
  final VoidCallback onTap;

  static String heroTag(int productId) => 'product-image-$productId';

  static TextStyle titleStyleOf(BuildContext context, double itemWidth) {
    final TextTheme text = Theme.of(context).textTheme;
    final TextStyle? style = itemWidth >= wideTitleWidth
        ? text.headlineMedium
        : text.bodyMedium;
    return style ?? const TextStyle(fontSize: 16, height: 1.5);
  }

  static double textBlockExtent(BuildContext context, double itemWidth) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextStyle title = titleStyleOf(context, itemWidth);
    final TextStyle price =
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 16, height: 1.5);
    final double titleLine = _lineExtent(title, scaler);
    final double priceLine = _lineExtent(price, scaler);
    final double badge = scaler.scale(_ratingBadgeExtent);
    return AppDimens.s16 +
        titleLine * titleMaxLines +
        AppDimens.s8 +
        math.max(priceLine, badge);
  }

  static double _lineExtent(TextStyle style, TextScaler scaler) {
    final double fontSize = scaler.scale(style.fontSize ?? 16);
    return fontSize * (style.height ?? 1.4);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double itemWidth = constraints.maxWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Hero(
                        tag: heroTag(product.id),
                        child: AppNetworkImage(
                          url: product.thumbnail,
                          fit: BoxFit.contain,
                          borderRadius: AppDimens.brCard,
                          backgroundColor: AppColors.productCardSurfaceOf(
                            context,
                          ),
                          semanticLabel: product.title,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: AppDimens.s8 / 2,
                      end: AppDimens.s8 / 2,
                      child: FavoriteButton(product: product),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              Text(
                product.title,
                textAlign: TextAlign.start,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: titleStyleOf(context, itemWidth),
              ),
              const SizedBox(height: AppDimens.s8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      Formatters.price(product.price),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.s8),
                  RatingBadge(rating: product.rating),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
