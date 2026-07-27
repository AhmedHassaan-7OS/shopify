import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/favorite_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/rating_stars.dart';
import '../../data/models/product_model.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/favorites/favorites_state.dart';
import 'widgets/bento_info_grid.dart';
import 'widgets/product_gallery.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({required this.product, super.key});

  static const double maxContentWidth = 640.0;

  static const String addLabel = 'إضافة إلى المفضّلة';

  static const String removeLabel = 'إزالة من المفضّلة';

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BrandAppBar(
        showBack: true,
        actions: <Widget>[
          FavoriteButton(product: product),
          const SizedBox(width: AppDimens.s8),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: AppDimens.s24,
                  end: AppDimens.s24,
                  top:
                      MediaQuery.paddingOf(context).top +
                      kToolbarHeight +
                      AppDimens.s16,
                  bottom: AppDimens.s32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ProductGallery(product: product),
                    const SizedBox(height: AppDimens.s24),
                    Text(
                      product.title,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      Formatters.price(product.price),
                      textAlign: TextAlign.start,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimens.s16),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: RatingStars(rating: product.rating),
                    ),
                    const SizedBox(height: AppDimens.s24),
                    BentoInfoGrid(product: product),
                    const SizedBox(height: AppDimens.s24),
                    Text(
                      _descriptionTitle,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      product.description,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _FavoriteActionBar(product: product),
    );
  }

  static const String _descriptionTitle = 'الوصف';
}

class _FavoriteActionBar extends StatelessWidget {
  const _FavoriteActionBar({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: BorderDirectional(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(AppDimens.s16),
        child: BlocSelector<FavoritesCubit, FavoritesState, bool>(
          selector: (FavoritesState state) => state.ids.contains(product.id),
          builder: (BuildContext context, bool isFavorite) => PrimaryButton(
            label: isFavorite
                ? ProductDetailsScreen.removeLabel
                : ProductDetailsScreen.addLabel,
            onPressed: () => context.read<FavoritesCubit>().toggle(product),
          ),
        ),
      ),
    );
  }
}
