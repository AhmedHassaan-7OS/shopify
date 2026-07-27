import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'shimmer_box.dart';

class ShimmerMetrics {
  const ShimmerMetrics._();

  static const double categoryTileExtent = 200.0;

  static const double categoryFeaturedTileExtent = 416.0;

  static const int categoryColumns = 2;

  static const double wideBreakpoint = 600.0;

  static const double productTextBlockExtent = 54.0;

  static const double favoriteThumbExtent = 72.0;

  static int productColumnsFor(double width) => width >= wideBreakpoint ? 3 : 2;
}

class CategoriesShimmerGrid extends StatelessWidget {
  const CategoriesShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.padding = EdgeInsetsDirectional.zero,
  });

  final int itemCount;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    int itemCount = 6,
    EdgeInsetsDirectional padding = EdgeInsetsDirectional.zero,
  }) => SliverToBoxAdapter(
    child: CategoriesShimmerGrid(itemCount: itemCount, padding: padding),
  );

  @override
  Widget build(BuildContext context) {
    final List<List<double>> columns = <List<double>>[<double>[], <double>[]];
    final List<double> heights = <double>[0, 0];

    for (int i = 0; i < itemCount; i++) {
      final double extent = (i + 1) % 3 == 0
          ? ShimmerMetrics.categoryFeaturedTileExtent
          : ShimmerMetrics.categoryTileExtent;
      final int target = heights[0] <= heights[1] ? 0 : 1;
      columns[target].add(extent);
      heights[target] += extent + AppDimens.s16;
    }

    return Padding(
      padding: padding,
      child: AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (
              int c = 0;
              c < ShimmerMetrics.categoryColumns;
              c++
            ) ...<Widget>[
              if (c > 0) const SizedBox(width: AppDimens.s16),
              Expanded(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < columns[c].length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: AppDimens.s16),
                      ShimmerBox(
                        height: columns[c][i],
                        borderRadius: AppDimens.brFeature,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProductsShimmerGrid extends StatelessWidget {
  const ProductsShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.padding = EdgeInsetsDirectional.zero,
  });

  final int itemCount;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    int itemCount = 6,
    EdgeInsetsDirectional padding = EdgeInsetsDirectional.zero,
  }) => SliverToBoxAdapter(
    child: ProductsShimmerGrid(itemCount: itemCount, padding: padding),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppShimmer(child: _ProductsGridSkeleton(itemCount: itemCount)),
    );
  }
}

class _ProductsGridSkeleton extends StatelessWidget {
  const _ProductsGridSkeleton({required this.itemCount});

  final int itemCount;

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
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppDimens.s16,
            mainAxisSpacing: AppDimens.s24,
            mainAxisExtent: imageExtent + ShimmerMetrics.productTextBlockExtent,
          ),
          itemBuilder: (BuildContext context, int index) =>
              _ProductCardShimmer(imageExtent: imageExtent),
        );
      },
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  const _ProductCardShimmer({required this.imageExtent});

  final double imageExtent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ShimmerBox(height: imageExtent, borderRadius: AppDimens.brCard),
        const SizedBox(height: AppDimens.s16),
        const ShimmerBox(height: 14),
        const SizedBox(height: AppDimens.s8),
        const FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 0.45,
          child: ShimmerBox(height: 12),
        ),
      ],
    );
  }
}

class SearchShimmer extends StatelessWidget {
  const SearchShimmer({
    super.key,
    this.categoryCount = 3,
    this.productCount = 4,
    this.padding = EdgeInsetsDirectional.zero,
  });

  final int categoryCount;

  final int productCount;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    int categoryCount = 3,
    int productCount = 4,
    EdgeInsetsDirectional padding = EdgeInsetsDirectional.zero,
  }) => SliverToBoxAdapter(
    child: SearchShimmer(
      categoryCount: categoryCount,
      productCount: productCount,
      padding: padding,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.3,
              child: ShimmerBox(height: 16),
            ),
            const SizedBox(height: AppDimens.s16),
            Wrap(
              spacing: AppDimens.s8,
              runSpacing: AppDimens.s8,
              children: <Widget>[
                for (int i = 0; i < categoryCount; i++)
                  const ShimmerBox(
                    width: 104,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.s32),
            const FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.3,
              child: ShimmerBox(height: 16),
            ),
            const SizedBox(height: AppDimens.s16),
            _ProductsGridSkeleton(itemCount: productCount),
          ],
        ),
      ),
    );
  }
}

class FavoritesShimmerList extends StatelessWidget {
  const FavoritesShimmerList({
    super.key,
    this.itemCount = 5,
    this.padding = EdgeInsetsDirectional.zero,
  });

  final int itemCount;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    int itemCount = 5,
    EdgeInsetsDirectional padding = EdgeInsetsDirectional.zero,
  }) => SliverToBoxAdapter(
    child: FavoritesShimmerList(itemCount: itemCount, padding: padding),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppShimmer(
        child: Column(
          children: <Widget>[
            for (int i = 0; i < itemCount; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: AppDimens.s16),
              const _FavoriteTileShimmer(),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavoriteTileShimmer extends StatelessWidget {
  const _FavoriteTileShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const ShimmerBox(
          width: ShimmerMetrics.favoriteThumbExtent,
          height: ShimmerMetrics.favoriteThumbExtent,
          borderRadius: AppDimens.brInput,
        ),
        const SizedBox(width: AppDimens.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              ShimmerBox(height: 14),
              SizedBox(height: AppDimens.s8),
              FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: 0.4,
                child: ShimmerBox(height: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.s16),
        const ShimmerBox(width: 24, height: 24, borderRadius: AppDimens.brCard),
      ],
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({
    super.key,
    this.infoTileCount = 3,
    this.padding = EdgeInsetsDirectional.zero,
  });

  final int infoTileCount;

  final EdgeInsetsDirectional padding;

  static Widget sliver({
    int infoTileCount = 3,
    EdgeInsetsDirectional padding = EdgeInsetsDirectional.zero,
  }) => SliverToBoxAdapter(
    child: ProfileShimmer(infoTileCount: infoTileCount, padding: padding),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppDimens.s32),
            Center(child: ShimmerBox.circle(size: AppDimens.avatarSize)),
            const SizedBox(height: AppDimens.s24),
            const Center(
              child: ShimmerBox(
                width: 160,
                height: 20,
                borderRadius: AppDimens.brInput,
              ),
            ),
            const SizedBox(height: AppDimens.s32),
            for (int i = 0; i < infoTileCount; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: AppDimens.s16),
              const ShimmerBox(height: 72, borderRadius: AppDimens.brCard),
            ],
            const SizedBox(height: AppDimens.s32),
            const ShimmerBox(
              height: AppDimens.buttonHeight,
              borderRadius: AppDimens.brCard,
            ),
          ],
        ),
      ),
    );
  }
}
