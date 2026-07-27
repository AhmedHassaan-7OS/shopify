import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'json_reader.dart';
import 'product_model.dart';

class FavoriteItem extends Equatable {
  FavoriteItem({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.thumbnail,
    DateTime? addedAt,
  }) : addedAt = addedAt?.toUtc();

  final int id;
  final String title;
  final double price;
  final double rating;
  final String thumbnail;

  final DateTime? addedAt;

  factory FavoriteItem.fromProduct(ProductModel product) => FavoriteItem(
    id: product.id,
    title: product.title,
    price: product.price,
    rating: product.rating,
    thumbnail: product.thumbnail,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'price': price,
    'rating': rating,
    'thumbnail': thumbnail,
    'addedAt': addedAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(addedAt!),
  };

  factory FavoriteItem.fromDoc(String documentId, Map<String, dynamic>? data) {
    final json = JsonReader.asMap(data);
    return FavoriteItem(
      id: JsonReader.intValue(
        json,
        'id',
        fallback: int.tryParse(documentId) ?? 0,
      ),
      title: JsonReader.string(json, 'title'),
      price: JsonReader.doubleValue(json, 'price'),
      rating: JsonReader.doubleValue(json, 'rating'),
      thumbnail: JsonReader.string(json, 'thumbnail'),
      addedAt: _parseDate(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'price': price,
    'rating': rating,
    'thumbnail': thumbnail,
    'addedAt': addedAt?.toIso8601String(),
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: JsonReader.intValue(json, 'id'),
    title: JsonReader.string(json, 'title'),
    price: JsonReader.doubleValue(json, 'price'),
    rating: JsonReader.doubleValue(json, 'rating'),
    thumbnail: JsonReader.string(json, 'thumbnail'),
    addedAt: _parseDate(json['addedAt']),
  );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      if (!value.isFinite) return null;
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    price,
    rating,
    thumbnail,
    addedAt,
  ];

  @override
  bool get stringify => true;
}
