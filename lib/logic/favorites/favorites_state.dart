import 'package:equatable/equatable.dart';

import '../../data/models/favorite_item_model.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  Set<int> get ids => const <int>{};

  @override
  List<Object?> get props => const <Object?>[];
}

final class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.ids, this.items);

  static const FavoritesLoaded empty = FavoritesLoaded(
    <int>{},
    <FavoriteItem>[],
  );

  @override
  final Set<int> ids;

  final List<FavoriteItem> items;

  @override
  List<Object?> get props => <Object?>[ids, items];
}

final class FavoritesError extends FavoritesState {
  const FavoritesError(this.message, this.ids);

  final String message;

  @override
  final Set<int> ids;

  @override
  List<Object?> get props => <Object?>[message, ids];
}
