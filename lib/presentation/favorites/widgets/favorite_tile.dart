import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../data/models/favorite_item_model.dart';

class FavoriteTile extends StatelessWidget {
  const FavoriteTile({super.key, required this.item, this.onRemove});

  static const double thumbSize = 80.0;

  final FavoriteItem item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppDimens.brCard,
        boxShadow: AppDimens.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimens.s16,
          vertical: AppDimens.s12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: AppDimens.brInput,
              child: ColoredBox(
                color: AppColors.productCardSurfaceOf(context),
                child: AppNetworkImage(
                  url: item.thumbnail,
                  width: thumbSize,
                  height: thumbSize,
                  fit: BoxFit.contain,
                  semanticLabel: item.title,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.title,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.s8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Formatters.price(item.price),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppDimens.s8),
                      RatingBadge(rating: item.rating),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.s8),
            IconButton(
              onPressed: onRemove,
              tooltip: 'إزالة من المفضّلة',
              icon: Icon(Symbols.favorite, fill: 1, color: colors.error),
            ),
          ],
        ),
      ),
    );
  }
}
