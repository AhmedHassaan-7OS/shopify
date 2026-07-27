import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/shimmer_views.dart';
import '../../data/models/category_model.dart';
import '../../logic/categories/categories_cubit.dart';
import '../../logic/search/search_cubit.dart';
import '../products/products_screen.dart';
import 'widgets/category_tile.dart';
import 'widgets/home_search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onSearchRequested});

  static const String greeting = 'أهلًا بك في';

  static const String headline = 'تسوّق\nبأناقة';

  static const String sectionTitle = 'الأقسام';

  static const String emptyMessage = 'لا توجد أقسام لعرضها حاليًا.';

  final VoidCallback? onSearchRequested;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final CategoriesCubit categories = context.read<CategoriesCubit>();
    if (categories.state is CategoriesInitial) {
      categories.loadCategories();
    } else if (categories.state case final CategoriesLoaded loaded) {
      _publishCategoriesToSearch(loaded.categories);
    }
  }

  void _publishCategoriesToSearch(List<CategoryModel> categories) =>
      context.read<SearchCubit>().setCategories(categories);

  void _openCategory(CategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ProductsScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocListener<CategoriesCubit, CategoriesState>(
      listenWhen: (CategoriesState previous, CategoriesState current) =>
          current is CategoriesLoaded &&
          (previous is! CategoriesLoaded ||
              previous.categories != current.categories),
      listener: (BuildContext context, CategoriesState state) {
        if (state case final CategoriesLoaded loaded) {
          _publishCategoriesToSearch(loaded.categories);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const BrandAppBar(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsetsDirectional.only(
                top:
                    MediaQuery.paddingOf(context).top +
                    kToolbarHeight +
                    AppDimens.s24,
                start: AppDimens.s24,
                end: AppDimens.s24,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      HomeScreen.greeting,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      HomeScreen.headline,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppDimens.s32),
                    HomeSearchField(onTap: widget.onSearchRequested),
                    const SizedBox(height: AppDimens.s32),
                    Text(
                      HomeScreen.sectionTitle,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimens.s16),
                  ],
                ),
              ),
            ),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (BuildContext context, CategoriesState state) =>
                  switch (state) {
                    CategoriesInitial() ||
                    CategoriesLoading() => CategoriesShimmerGrid.sliver(
                      padding: AppDimens.screenPaddingDirectional,
                    ),
                    CategoriesEmpty() => AppEmptyView.sliver(
                      message: HomeScreen.emptyMessage,
                    ),
                    CategoriesError(message: final String message) =>
                      AppErrorView.sliver(
                        message: message,
                        onRetry: () =>
                            context.read<CategoriesCubit>().loadCategories(),
                      ),
                    CategoriesLoaded(
                      categories: final List<CategoryModel> categories,
                      thumbnails: final Map<String, String> thumbnails,
                    ) =>
                      _CategoriesGrid(
                        categories: categories,
                        thumbnails: thumbnails,
                        onCategorySelected: _openCategory,
                      ),
                  },
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    AppDimens.s32 + MediaQuery.paddingOf(context).bottom + 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({
    required this.categories,
    required this.thumbnails,
    required this.onCategorySelected,
  });

  final List<CategoryModel> categories;
  final Map<String, String> thumbnails;
  final ValueChanged<CategoryModel> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final List<List<int>> columns = <List<int>>[
      for (int c = 0; c < ShimmerMetrics.categoryColumns; c++) <int>[],
    ];
    final List<double> columnHeights = List<double>.filled(
      ShimmerMetrics.categoryColumns,
      0,
    );

    for (int i = 0; i < categories.length; i++) {
      int target = 0;
      for (int c = 1; c < columnHeights.length; c++) {
        if (columnHeights[c] < columnHeights[target]) target = c;
      }
      columns[target].add(i);
      columnHeights[target] += _extentOf(i) + AppDimens.s16;
    }

    return SliverPadding(
      padding: AppDimens.screenPaddingDirectional,
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int c = 0; c < columns.length; c++) ...<Widget>[
              if (c > 0) const SizedBox(width: AppDimens.s16),
              Expanded(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < columns[c].length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(height: AppDimens.s16),
                      _tileAt(columns[c][i]),
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

  double _extentOf(int index) => (index + 1) % 3 == 0
      ? ShimmerMetrics.categoryFeaturedTileExtent
      : ShimmerMetrics.categoryTileExtent;

  Widget _tileAt(int index) {
    final CategoryModel category = categories[index];
    return CategoryTile(
      category: category,
      orderNumber: index + 1,
      height: _extentOf(index),
      thumbnailUrl: thumbnails[category.slug],
      onTap: () => onCategorySelected(category),
    );
  }
}
