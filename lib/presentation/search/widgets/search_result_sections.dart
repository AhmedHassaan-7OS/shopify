import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../core/widgets/shimmer_views.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';

class SearchResultSections extends StatelessWidget {
  const SearchResultSections({
    super.key,
    required this.categories,
    required this.products,
    required this.onCategorySelected,
    required this.onProductSelected,
    this.padding = const EdgeInsetsDirectional.only(
      start: AppDimens.s24,
      end: AppDimens.s24,
      bottom: AppDimens.s32,
    ),
  });

  static const String categoriesSectionTitle = 'الأقسام';

  static const String productsSectionTitle = 'المنتجات';

  static const double textBlockExtent = 68.0;

  final List<CategoryModel> categories;

  final List<ProductModel> products;

  final ValueChanged<CategoryModel> onCategorySelected;

  final ValueChanged<ProductModel> onProductSelected;

  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: <Widget>[
        if (categories.isNotEmpty) ...<Widget>[
          const _SectionTitle(categoriesSectionTitle),
          Wrap(
            spacing: AppDimens.s8,
            runSpacing: AppDimens.s8,
            children: <Widget>[
              for (final CategoryModel category in categories)
                ActionChip(
                  label: Text(category.name),
                  onPressed: () => onCategorySelected(category),
                ),
            ],
          ),
        ],
        if (categories.isNotEmpty && products.isNotEmpty)
          const SizedBox(height: AppDimens.s32),
        if (products.isNotEmpty) ...<Widget>[
          const _SectionTitle(productsSectionTitle),
          _ProductsResultGrid(
            products: products,
            onProductSelected: onProductSelected,
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: AppDimens.s8,
        bottom: AppDimens.s16,
      ),
      child: Text(
        title,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ProductsResultGrid extends StatelessWidget {
  const _ProductsResultGrid({
    required this.products,
    required this.onProductSelected,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = ShimmerMetrics.productColumnsFor(
          constraints.maxWidth,
        );
        final double itemWidth =
            (constraints.maxWidth - AppDimens.s16 * (columns - 1)) / columns;
        final double imageExtent =
            itemWidth / AppDimens.productImageAspectRatio;

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppDimens.s16,
            mainAxisSpacing: AppDimens.s24,
            mainAxisExtent:
                imageExtent +
                AppDimens.s8 +
                SearchResultSections.textBlockExtent,
          ),
          itemBuilder: (BuildContext context, int index) {
            final ProductModel product = products[index];
            return _SearchProductCard(
              product: product,
              imageExtent: imageExtent,
              onTap: () => onProductSelected(product),
            );
          },
        );
      },
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({
    required this.product,
    required this.imageExtent,
    required this.onTap,
  });

  final ProductModel product;
  final double imageExtent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.brCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: imageExtent,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AppNetworkImage(
                    url: product.thumbnail,
                    fit: BoxFit.contain,
                    borderRadius: AppDimens.brCard,
                    backgroundColor: AppColors.productCardSurfaceOf(context),
                    semanticLabel: product.title,
                  ),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: FavoriteButton(product: product),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimens.s8 / 2),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        Formatters.price(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    RatingBadge(rating: product.rating),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
