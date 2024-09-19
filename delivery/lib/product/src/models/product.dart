import 'package:delivery/product/src/enitities/entities.dart';
import 'package:delivery/product/src/models/ingredients.dart';

class Product {
  String productID;
  String image;
  String name;
  String description;
  double price;
  Ingredients ingredients;

    Product({
    required this.productID,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.ingredients,
  });

  ProductEntity toEntity() {
    return ProductEntity(
      productID: productID,
      image: image,
      name: name,
      description: description,
      price: price,
      ingredients: ingredients,
    );
  }

  static Product fromEntity(ProductEntity entity) {
    return Product(
      productID: entity.productID,
      image: entity.image,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      ingredients: entity.ingredients,
   );
  }
}
