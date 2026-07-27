import 'package:equatable/equatable.dart';

import 'json_reader.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.slug,
    required this.name,
    required this.url,
  });

  final String slug;

  final String name;

  final String url;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    slug: JsonReader.string(json, 'slug'),
    name: JsonReader.string(json, 'name'),
    url: JsonReader.string(json, 'url'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'slug': slug,
    'name': name,
    'url': url,
  };

  static List<CategoryModel> listFromJson(dynamic decoded) {
    if (decoded is! List) return const <CategoryModel>[];
    return decoded
        .map((dynamic e) => CategoryModel.fromJson(JsonReader.asMap(e)))
        .toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[slug, name, url];

  @override
  bool get stringify => true;
}
