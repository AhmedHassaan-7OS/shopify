import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/error_mapper.dart';
import '../../data/models/favorite_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/services/auth_service.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required FavoritesRepository favoritesRepository,
    required AuthService authService,
  }) : _favoritesRepository = favoritesRepository,
       _authService = authService,
       super(const FavoritesInitial());

  final FavoritesRepository _favoritesRepository;
  final AuthService _authService;

  Future<void> load() async {
    final String? uid = _authService.currentUser?.uid;
    if (uid == null) {
      if (isClosed) return;
      emit(FavoritesLoaded.empty);
      return;
    }

    if (isClosed) return;
    emit(const FavoritesLoading());

    try {
      final List<FavoriteItem> items = await _favoritesRepository.getFavorites(
        uid,
      );
      if (isClosed) return;
      emit(
        FavoritesLoaded(
          items.map((FavoriteItem item) => item.id).toSet(),
          items,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(FavoritesError(ErrorMapper.fromUnknown(e).message, state.ids));
    }
  }

  Future<void> retry() => load();

  Future<void> toggle(ProductModel product) async {
    final String? uid = _authService.currentUser?.uid;
    if (uid == null) return;

    final Set<int> previousIds = state.ids;
    final List<FavoriteItem> previousItems = switch (state) {
      FavoritesLoaded(items: final List<FavoriteItem> items) => items,
      _ => const <FavoriteItem>[],
    };
    final bool wasFavorite = previousIds.contains(product.id);

    final Set<int> nextIds = wasFavorite
        ? (Set<int>.of(previousIds)..remove(product.id))
        : (Set<int>.of(previousIds)..add(product.id));
    final List<FavoriteItem> nextItems = wasFavorite
        ? previousItems
              .where((FavoriteItem item) => item.id != product.id)
              .toList(growable: false)
        : <FavoriteItem>[FavoriteItem.fromProduct(product), ...previousItems];

    if (isClosed) return;
    emit(FavoritesLoaded(nextIds, nextItems));

    try {
      if (wasFavorite) {
        await _favoritesRepository.remove(uid, product.id);
      } else {
        await _favoritesRepository.add(uid, FavoriteItem.fromProduct(product));
      }
    } catch (e) {
      if (isClosed) return;
      emit(FavoritesLoaded(previousIds, previousItems));
      emit(FavoritesError(ErrorMapper.fromUnknown(e).message, previousIds));
    }
  }

  bool isFavorite(int productId) => state.ids.contains(productId);

  void clear() {
    if (isClosed) return;
    emit(const FavoritesInitial());
  }
}
