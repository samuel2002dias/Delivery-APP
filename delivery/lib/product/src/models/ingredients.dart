import 'package:delivery/product/src/enitities/IngredientsEntity.dart';

class Ingredients {
  String ingredientID;
  String ingredientName1;
  String ingredientName2;
  String ingredientName3;
  String ingredientName4;

  Ingredients({
    required this.ingredientID,
    required this.ingredientName1,
    required this.ingredientName2,
    required this.ingredientName3,
    required this.ingredientName4,
  });

  IngredientsEntity toEntity() {
    return IngredientsEntity(
      ingredientID: ingredientID,
      ingredientName1: ingredientName1,
      ingredientName2: ingredientName2,
      ingredientName3: ingredientName3,
      ingredientName4: ingredientName4,
    );
  }

  static Ingredients fromEntity(Ingredients entity) {
    return Ingredients(
      ingredientID: entity.ingredientID,
      ingredientName1: entity.ingredientName1,
      ingredientName2: entity.ingredientName2,
      ingredientName3: entity.ingredientName3,
      ingredientName4: entity.ingredientName4,
    );
  }
}
