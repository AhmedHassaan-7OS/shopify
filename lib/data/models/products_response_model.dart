import 'package:equatable/equatable.dart';

import 'json_reader.dart';
import 'product_model.dart';

class ProductsResponseModel extends Equatable {
  const ProductsResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) =>
      ProductsResponseModel(
        products: JsonReader.mapList(
          json,
          'products',
        ).map(ProductModel.fromJson).toList(growable: false),
        total: JsonReader.intValue(json, 'total'),
        skip: JsonReader.intValue(json, 'skip'),
        limit: JsonReader.intValue(json, 'limit'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'products': products
        .map((ProductModel p) => p.toJson())
        .toList(growable: false),
    'total': total,
    'skip': skip,
    'limit': limit,
  };

  static const ProductsResponseModel empty = ProductsResponseModel(
    products: <ProductModel>[],
    total: 0,
    skip: 0,
    limit: 0,
  );

  @override
  List<Object?> get props => <Object?>[products, total, skip, limit];

  @override
  bool get stringify => true;
}
