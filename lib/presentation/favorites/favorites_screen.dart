import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/shimmer_views.dart';
import '../../data/models/favorite_item_model.dart';
import '../../data/models/product_model.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/favorites/favorites_state.dart';
import 'widgets/favorite_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const String title = 'المفضّلة';

  static const String emptyMessage =
      'لا توجد منتجات في المفضّلة بعد.\nاضغط على القلب في أي منتج ليظهر هنا.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const BrandAppBar(title: title),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listenWhen: (FavoritesState previous, FavoritesState current) =>
            current is FavoritesError && previous is FavoritesLoaded,
        listener: (BuildContext context, FavoritesState state) {
          if (state is! FavoritesError) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        },
        buildWhen: (FavoritesState previous, FavoritesState current) =>
            !(current is FavoritesError && previous is FavoritesLoaded),
        builder: (BuildContext context, FavoritesState state) {
          return _FavoritesBody(state: state);
        },
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody({required this.state});

  final FavoritesState state;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double navBarHeight = MediaQuery.paddingOf(context).bottom + 80;
    final double topInset = statusBarHeight + kToolbarHeight + AppDimens.s16;
    final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
      start: AppDimens.s24,
      end: AppDimens.s24,
      top: topInset,
      bottom: AppDimens.s32 + navBarHeight,
    );

    return switch (state) {
      FavoritesInitial() || FavoritesLoading() => SingleChildScrollView(
        child: FavoritesShimmerList(padding: padding),
      ),
      FavoritesLoaded(items: final List<FavoriteItem> items) =>
        items.isEmpty
            ? _EmptyFavorites(padding: padding)
            : _FavoritesList(items: items, padding: padding),
      FavoritesError(message: final String message) => Padding(
        padding: EdgeInsetsDirectional.only(top: topInset),
        child: AppErrorView(
          message: message,
          onRetry: () => context.read<FavoritesCubit>().retry(),
        ),
      ),
    };
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.items, required this.padding});

  final List<FavoriteItem> items;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppDimens.s16),
      itemBuilder: (BuildContext context, int index) {
        final FavoriteItem item = items[index];
        return FavoriteTile(
          item: item,
          onRemove: () =>
              context.read<FavoritesCubit>().toggle(_productOf(item)),
        );
      },
    );
  }

  static ProductModel _productOf(FavoriteItem item) => ProductModel(
    id: item.id,
    title: item.title,
    description: '',
    category: '',
    price: item.price,
    rating: item.rating,
    thumbnail: item.thumbnail,
    images: const <String>[],
    brand: '',
    stock: 0,
  );
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.padding});

  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      message: FavoritesScreen.emptyMessage,
      icon: Symbols.favorite,
      padding: padding,
    );
  }
}
