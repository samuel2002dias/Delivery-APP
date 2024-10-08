// ignore_for_file: file_names

import 'package:delivery/product/src/enitities/IngredientsEntity.dart';
import 'package:delivery/product/src/models/models.dart';

class ProductEntity {
  String productID;
  String image;
  String name;
  String description;
  double price;
  Ingredients ingredients;

  ProductEntity({
    required this.productID,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.ingredients,
  });

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'image': image,
      'name': name,
      'description': description,
      'price': price,
      'ingredients': ingredients.toEntity().toJSON(),
    };
  }

  static ProductEntity fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      productID: json['productID'] as String,
      image: json['image'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      ingredients: Ingredients.fromEntity(
          IngredientsEntity.fromJSON(json['ingredients']) as Ingredients),
    );
  }
}
