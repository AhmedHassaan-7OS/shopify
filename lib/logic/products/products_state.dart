import 'package:equatable/equatable.dart';

import '../../data/models/product_model.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded(this.products);

  final List<ProductModel> products;

  @override
  List<Object?> get props => <Object?>[products];
}

final class ProductsEmpty extends ProductsState {
  const ProductsEmpty();
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
