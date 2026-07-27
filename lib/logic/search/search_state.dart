import 'package:equatable/equatable.dart';

import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded(this.query, this.categories, this.products);

  final String query;

  final List<CategoryModel> categories;
  final List<ProductModel> products;

  @override
  List<Object?> get props => <Object?>[query, categories, products];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
