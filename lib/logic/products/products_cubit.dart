import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/error_mapper.dart';
import '../../core/errors/failure.dart';
import '../../data/models/products_response_model.dart';
import '../../data/repositories/catalog_repository.dart';
import 'products_state.dart';

export 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._catalog) : super(const ProductsInitial());

  final CatalogRepository _catalog;

  Future<void> loadProducts(String slug) async {
    emit(const ProductsLoading());
    final ProductsResponseModel response;
    try {
      response = await _catalog.getProductsByCategory(slug);
    } catch (e) {
      if (isClosed) return;
      emit(ProductsError(_messageOf(e)));
      return;
    }
    if (isClosed) return;
    if (response.products.isEmpty) {
      emit(const ProductsEmpty());
      return;
    }
    emit(ProductsLoaded(response.products));
  }

  String _messageOf(Object error) =>
      error is Failure ? error.message : ErrorMapper.fromUnknown(error).message;
}
