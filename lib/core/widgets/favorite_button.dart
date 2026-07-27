import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/models/product_model.dart';
import '../../logic/favorites/favorites_cubit.dart';
import '../../logic/favorites/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.product,
    this.size = _defaultIconSize,
    super.key,
  });

  static const double _defaultIconSize = 24.0;

  final ProductModel product;

  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (FavoritesState state) => state.ids.contains(product.id),
      builder: (BuildContext context, bool isFavorite) {
        return IconButton(
          onPressed: () => context.read<FavoritesCubit>().toggle(product),
          iconSize: size,
          tooltip: isFavorite ? 'إزالة من المفضّلة' : 'إضافة إلى المفضّلة',
          icon: Icon(
            Symbols.favorite,
            fill: isFavorite ? 1 : 0,
            size: size,
            color: isFavorite ? colors.error : colors.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
