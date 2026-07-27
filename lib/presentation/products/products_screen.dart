import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/shimmer_views.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../logic/products/products_cubit.dart';
import 'product_details_screen.dart';
import 'widgets/product_card.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({
    required this.category,
    this.catalogRepository,
    super.key,
  });

  final CategoryModel category;

  final CatalogRepository? catalogRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (BuildContext context) =>
          ProductsCubit(_resolveRepository(context))
            ..loadProducts(category.slug),
      child: _ProductsView(category: category),
    );
  }

  CatalogRepository _resolveRepository(BuildContext context) {
    if (catalogRepository != null) return catalogRepository!;
    final bool hasProvider =
        context
            .findAncestorWidgetOfExactType<
              RepositoryProvider<CatalogRepository>
            >() !=
        null;
    return hasProvider
        ? RepositoryProvider.of<CatalogRepository>(context)
        : CatalogRepository();
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView({required this.category});

  static const String emptyMessage = 'لا توجد منتجات في هذا القسم حاليًا.';

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const BrandAppBar(showBack: true),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsetsDirectional.only(
                  top:
                      MediaQuery.paddingOf(context).top +
                      kToolbarHeight +
                      AppDimens.s16,
                  start: AppDimens.s24,
                  end: AppDimens.s24,
                  bottom: AppDimens.s24,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    category.name,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
              ),
              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (BuildContext context, ProductsState state) =>
                    switch (state) {
                      ProductsInitial() ||
                      ProductsLoading() => ProductsShimmerGrid.sliver(
                        padding: AppDimens.screenPaddingDirectional,
                      ),
                      ProductsEmpty() => AppEmptyView.sliver(
                        message: emptyMessage,
                      ),
                      ProductsError(message: final String message) =>
                        AppErrorView.sliver(
                          message: message,
                          onRetry: () => context
                              .read<ProductsCubit>()
                              .loadProducts(category.slug),
                        ),
                      ProductsLoaded(
                        products: final List<ProductModel> products,
                      ) =>
                        _ProductsGrid(
                          products: products,
                          availableWidth: constraints.maxWidth,
                        ),
                    },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppDimens.s32)),
            ],
          );
        },
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({required this.products, required this.availableWidth});

  final List<ProductModel> products;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final int columns = ShimmerMetrics.productColumnsFor(availableWidth);
    final double contentWidth = math.max(availableWidth - AppDimens.s24 * 2, 1);
    final double itemWidth = math.max(
      (contentWidth - AppDimens.s16 * (columns - 1)) / columns,
      1,
    );
    final double imageExtent = itemWidth / AppDimens.productImageAspectRatio;
    final double itemExtent =
        imageExtent + ProductCard.textBlockExtent(context, itemWidth);

    return SliverPadding(
      padding: AppDimens.screenPaddingDirectional,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppDimens.s16,
          mainAxisSpacing: AppDimens.s24,
          mainAxisExtent: itemExtent,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          final ProductModel product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext _) =>
                    ProductDetailsScreen(product: product),
              ),
            ),
          );
        }, childCount: products.length),
      ),
    );
  }
}
