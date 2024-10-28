// ignore_for_file: file_names

class IngredientsEntity {
  String ingredientID;
  String ingredientName1;
  String ingredientName2;
  String ingredientName3;
  String ingredientName4;

  IngredientsEntity({
    required this.ingredientID,
    required this.ingredientName1,
    required this.ingredientName2,
    required this.ingredientName3,
    required this.ingredientName4,
  });

  Map<String, dynamic> toJSON() {
    return {
      'ingredientID': ingredientID,
      'ingredientName1': ingredientName1,
      'ingredientName2': ingredientName2,
      'ingredientName3': ingredientName3,
      'ingredientName4': ingredientName4,
    };
  }

  static IngredientsEntity fromJSON(Map<String, dynamic> json) {
    return IngredientsEntity(
      ingredientID: json['ingredientID'] as String,
      ingredientName1: json['ingredientName1'] as String,
      ingredientName2: json['ingredientName2'] as String,
      ingredientName3: json['ingredientName3'] as String,
      ingredientName4: json['ingredientName4'] as String,
    );
  }
}
