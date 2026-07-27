import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../data/models/product_model.dart';

/// شبكة معلومات بخليتين (bento grid) أسفل عنوان المنتج: العلامة التجارية
/// والمخزون (Requirements 8.6, 8.7).
///
/// عندما تكون `brand` نصًا فارغًا تُعرض `category` بدلًا منها عبر
/// [brandValueOf]، فلا تظهر خلية بلا قيمة.
class BentoInfoGrid extends StatelessWidget {
  const BentoInfoGrid({required this.product, super.key});

  /// عنوان خلية العلامة التجارية.
  static const String brandLabel = 'العلامة التجارية';

  /// عنوان خلية المخزون.
  static const String stockLabel = 'المخزون';

  /// المنتج المعروض.
  final ProductModel product;

  /// قيمة خلية العلامة التجارية: `brand` أو `category` عند فراغها
  /// (Requirement 8.7).
  static String brandValueOf(ProductModel product) =>
      product.brand.trim().isEmpty ? product.category : product.brand;

  /// قيمة خلية المخزون كنص.
  static String stockValueOf(ProductModel product) => '${product.stock}';

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight يجعل الخليتين بنفس الارتفاع داخل عمود غير محدود
    // الارتفاع (الشاشة قابلة للتمرير) بدل ارتفاع لا نهائي.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _BentoCell(
              icon: Symbols.sell,
              label: brandLabel,
              value: brandValueOf(product),
            ),
          ),
          const SizedBox(width: AppDimens.s16),
          Expanded(
            child: _BentoCell(
              icon: Symbols.inventory_2,
              label: stockLabel,
              value: stockValueOf(product),
            ),
          ),
        ],
      ),
    );
  }
}

/// خلية واحدة: أيقونة + عنوان صغير + القيمة.
class _BentoCell extends StatelessWidget {
  const _BentoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppDimens.brFeature,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppDimens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: AppDimens.s24, color: colors.onSurfaceVariant),
            const SizedBox(height: AppDimens.s8),
            Text(
              label,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.s8 / 2),
            Text(
              value,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
