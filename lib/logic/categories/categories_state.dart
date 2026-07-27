import 'package:equatable/equatable.dart';

import '../../data/models/category_model.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(
    this.categories, {
    this.thumbnails = const <String, String>{},
  });

  final List<CategoryModel> categories;
  final Map<String, String> thumbnails;

  CategoriesLoaded withThumbnails(Map<String, String> thumbnails) =>
      CategoriesLoaded(categories, thumbnails: thumbnails);

  @override
  List<Object?> get props => <Object?>[categories, thumbnails];
}

final class CategoriesEmpty extends CategoriesState {
  const CategoriesEmpty();
}

final class CategoriesError extends CategoriesState {
  const CategoriesError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
