import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failure.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/catalog_repository.dart';
import 'categories_state.dart';

export 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._catalog) : super(const CategoriesInitial());

  final CatalogRepository _catalog;

  Future<void> loadCategories() async {
    emit(const CategoriesLoading());
    final List<CategoryModel> categories;
    try {
      categories = await _catalog.getCategories();
    } catch (e) {
      if (isClosed) return;
      emit(CategoriesError(_messageOf(e)));
      return;
    }
    if (isClosed) return;
    if (categories.isEmpty) {
      emit(const CategoriesEmpty());
      return;
    }
    emit(CategoriesLoaded(categories));
    await _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    final Map<String, String> thumbnails;
    try {
      thumbnails = await _catalog.getCategoryThumbnails();
    } catch (_) {
      return;
    }
    if (isClosed || thumbnails.isEmpty) return;
    final CategoriesState current = state;
    if (current is! CategoriesLoaded) return;
    emit(current.withThumbnails(thumbnails));
  }

  String _messageOf(Object error) =>
      error is Failure ? error.message : ErrorMapper.fromUnknown(error).message;
}
