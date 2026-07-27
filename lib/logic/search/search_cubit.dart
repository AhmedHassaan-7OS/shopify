import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/utils/debouncer.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/products_response_model.dart';
import '../../data/repositories/catalog_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required CatalogRepository catalogRepository,
    Duration debounceDelay = Debouncer.defaultDelay,
  }) : _catalogRepository = catalogRepository,
       _debouncer = Debouncer(delay: debounceDelay),
       super(const SearchIdle());

  final CatalogRepository _catalogRepository;
  final Debouncer _debouncer;

  static const int minQueryLength = 2;

  List<CategoryModel> _categories = const <CategoryModel>[];

  String _lastQuery = '';

  int _requestId = 0;

  void setCategories(List<CategoryModel> categories) {
    _categories = List<CategoryModel>.unmodifiable(categories);
  }

  void onQueryChanged(String query) {
    final String trimmed = query.trim();
    _lastQuery = trimmed;
    if (trimmed.length < minQueryLength) {
      _debouncer.cancel();
      _requestId++;
      if (isClosed) return;
      emit(const SearchIdle());
      return;
    }
    _debouncer.run(() => search(trimmed));
  }

  Future<void> search(String query) async {
    final String trimmed = query.trim();
    _lastQuery = trimmed;
    _debouncer.cancel();

    if (trimmed.length < minQueryLength) {
      if (isClosed) return;
      emit(const SearchIdle());
      return;
    }

    final int requestId = ++_requestId;
    if (isClosed) return;
    emit(const SearchLoading());

    final List<CategoryModel> categories = _filterCategories(trimmed);
    try {
      final ProductsResponseModel response = await _catalogRepository
          .searchProducts(trimmed);
      if (isClosed || requestId != _requestId) return;
      final List<ProductModel> products = response.products;
      if (categories.isEmpty && products.isEmpty) {
        emit(SearchEmpty(trimmed));
        return;
      }
      emit(SearchLoaded(trimmed, categories, products));
    } catch (e) {
      if (isClosed || requestId != _requestId) return;
      emit(SearchError(ErrorMapper.fromUnknown(e).message));
    }
  }

  Future<void> retry() => search(_lastQuery);

  List<CategoryModel> _filterCategories(String query) {
    final String needle = query.toLowerCase();
    return _categories
        .where(
          (CategoryModel category) =>
              category.name.toLowerCase().contains(needle) ||
              category.slug.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
