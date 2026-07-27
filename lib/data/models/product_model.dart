import 'package:equatable/equatable.dart';

import 'json_reader.dart';

class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.images,
    required this.brand,
    required this.stock,
  });

  final int id;
  final String title;
  final String description;

  final String category;

  final double price;

  final double rating;

  final String thumbnail;

  final List<String> images;

  final String brand;

  final int stock;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: JsonReader.intValue(json, 'id'),
    title: JsonReader.string(json, 'title'),
    description: JsonReader.string(json, 'description'),
    category: JsonReader.string(json, 'category'),
    price: JsonReader.doubleValue(json, 'price'),
    rating: JsonReader.doubleValue(json, 'rating'),
    thumbnail: JsonReader.string(json, 'thumbnail'),
    images: JsonReader.stringList(json, 'images'),
    brand: JsonReader.string(json, 'brand'),
    stock: JsonReader.intValue(json, 'stock'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'rating': rating,
    'thumbnail': thumbnail,
    'images': images,
    'brand': brand,
    'stock': stock,
  };

  List<String> get galleryImages =>
      images.isNotEmpty ? images : <String>[thumbnail];

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    description,
    category,
    price,
    rating,
    thumbnail,
    images,
    brand,
    stock,
  ];

  @override
  bool get stringify => true;
}
