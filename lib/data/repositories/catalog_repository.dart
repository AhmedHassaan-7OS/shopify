import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/error_mapper.dart';
import '../../core/errors/failure.dart';
import '../models/category_model.dart';
import '../models/json_reader.dart';
import '../models/products_response_model.dart';
import '../services/api_provider.dart';

class CatalogRepository {
  CatalogRepository({ApiProvider? apiProvider})
    : _api = apiProvider ?? ApiProvider();

  final ApiProvider _api;

  Future<List<CategoryModel>> getCategories() => _guard(
    () async =>
        CategoryModel.listFromJson(await _api.get(ApiConstants.categoriesPath)),
  );

  Future<Map<String, String>> getCategoryThumbnails() => _guard(() async {
    final dynamic data = await _api.get(
      ApiConstants.productsPath,
      queryParameters: <String, dynamic>{
        'limit': 0,
        'select': ApiConstants.categoryThumbnailSelectFields,
      },
    );
    final List<Map<String, dynamic>> products = JsonReader.mapList(
      JsonReader.asMap(data),
      'products',
    );
    final Map<String, String> thumbnails = <String, String>{};
    for (final Map<String, dynamic> product in products) {
      final String slug = JsonReader.string(product, 'category');
      final String thumbnail = JsonReader.string(product, 'thumbnail');
      if (slug.isEmpty || thumbnail.isEmpty) continue;
      thumbnails.putIfAbsent(slug, () => thumbnail);
    }
    return Map<String, String>.unmodifiable(thumbnails);
  });

  Future<ProductsResponseModel> getProductsByCategory(String slug) =>
      _guard(() async {
        final dynamic data = await _api.get(
          '${ApiConstants.productsByCategoryPath}/${Uri.encodeComponent(slug)}',
          queryParameters: <String, dynamic>{
            'select': ApiConstants.productSelectFields,
          },
        );
        return ProductsResponseModel.fromJson(JsonReader.asMap(data));
      });

  Future<ProductsResponseModel> searchProducts(String query) =>
      _guard(() async {
        final dynamic data = await _api.get(
          ApiConstants.searchPath,
          queryParameters: <String, dynamic>{
            'q': query,
            'select': ApiConstants.productSelectFields,
          },
        );
        return ProductsResponseModel.fromJson(JsonReader.asMap(data));
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ErrorMapper.fromUnknown(e);
    }
  }
}
