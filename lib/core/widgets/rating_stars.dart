import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_dimens.dart';
import '../utils/formatters.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.size = _defaultStarSize,
    this.showValue = true,
    super.key,
  });

  static const int starCount = 5;

  static const double _defaultStarSize = 20.0;

  static const double _halfThreshold = 0.5;

  final double rating;

  final double size;

  final bool showValue;

  static double clampRating(double value) {
    if (value.isNaN) return 0;
    return value.clamp(0, starCount.toDouble()).toDouble();
  }

  static int filledStars(double value) => clampRating(value).floor();

  static bool hasHalfStar(double value) {
    final double clamped = clampRating(value);
    final int filled = clamped.floor();
    if (filled >= starCount) return false;
    return clamped - filled >= _halfThreshold;
  }

  Widget _star({
    required int index,
    required int filled,
    required bool half,
    required ColorScheme colors,
  }) {
    if (index < filled) {
      return Icon(Symbols.star, fill: 1, size: size, color: colors.onSurface);
    }
    if (index == filled && half) {
      return Icon(
        Symbols.star_half,
        fill: 1,
        size: size,
        color: colors.onSurface,
      );
    }
    return Icon(
      Symbols.star,
      fill: 0,
      size: size,
      color: colors.outlineVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int filled = filledStars(rating);
    final bool half = hasHalfStar(rating);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < starCount; index++)
          _star(index: index, filled: filled, half: half, colors: colors),
        if (showValue) ...<Widget>[
          const SizedBox(width: AppDimens.s8),
          Text(
            Formatters.rating(rating),
            textAlign: TextAlign.start,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
