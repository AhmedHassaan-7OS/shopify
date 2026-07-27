import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_dimens.dart';
import '../utils/formatters.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.rating, super.key});

  static const double backgroundOpacity = 0.05;

  static const double _iconSize = 14.0;
  static const double _verticalPadding = 4.0;

  final double rating;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: backgroundOpacity),
        borderRadius: const BorderRadius.all(Radius.circular(AppDimens.s16)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimens.s8,
          vertical: _verticalPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Symbols.star,
              fill: 1,
              size: _iconSize,
              color: colors.onSurface,
            ),
            const SizedBox(width: AppDimens.s8 / 2),
            Text(
              Formatters.rating(rating),
              textAlign: TextAlign.start,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
