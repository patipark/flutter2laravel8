// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  Product({
    @required this.id,
    @required this.name,
    @required this.slug,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.createdAt,
    @required this.updatedAt,
  });

  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final String? price;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        slug: json["slug"] == null ? null : json["slug"],
        description: json["description"] == null ? null : json["description"],
        price: json["price"] == null ? null : json["price"],
        imageUrl: json["image_url"] == null ? null : json["image_url"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "slug": slug == null ? null : slug,
        "description": description == null ? null : description,
        "price": price == null ? null : price,
        "image_url": imageUrl == null ? null : imageUrl,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
      };
}
