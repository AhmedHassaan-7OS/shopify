import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../data/models/category_model.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.orderNumber,
    required this.height,
    this.thumbnailUrl,
    this.onTap,
  });

  static const double gradientMaxOpacity = 0.7;

  final CategoryModel category;
  final int orderNumber;
  final double height;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  bool get _hasThumbnail => (thumbnailUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final String heroTag = 'category-${category.slug}';

    return Semantics(
      button: true,
      label: category.name,
      child: Hero(
        tag: heroTag,
        flightShuttleBuilder: _shuttleBuilder,
        child: SizedBox(
          height: height,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: AppDimens.brFeature,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: _hasThumbnail
                  ? _ImageTileContent(
                      category: category,
                      thumbnailUrl: thumbnailUrl!,
                    )
                  : _TypographicTileContent(
                      category: category,
                      orderNumber: orderNumber,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _shuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return FadeTransition(opacity: animation, child: fromHeroContext.widget);
  }
}

class _ImageTileContent extends StatelessWidget {
  const _ImageTileContent({required this.category, required this.thumbnailUrl});

  final CategoryModel category;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color scrim = theme.colorScheme.scrim;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AppNetworkImage(
          url: thumbnailUrl,
          fit: BoxFit.cover,
          semanticLabel: category.name,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                scrim.withValues(alpha: CategoryTile.gradientMaxOpacity),
                scrim.withValues(alpha: 0),
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(AppDimens.s16),
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Text(
              category.name,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypographicTileContent extends StatelessWidget {
  const _TypographicTileContent({
    required this.category,
    required this.orderNumber,
  });

  final CategoryModel category;
  final int orderNumber;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.all(AppDimens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            orderNumber.toString().padLeft(2, '0'),
            textAlign: TextAlign.start,
            maxLines: 1,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            category.name,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
