class MyUserEntity {
  String userId;
  String email;
  String name;
  bool hasCart;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasCart,
  });

// The `toJson()` function converts object properties to a map with string keys and
// nullable values.
// 
// Returns:
//   A `Map<String, Object?>` is being returned. The map contains key-value pairs
// where the keys are strings and the values are objects or null. The keys in the
// map are 'userId', 'email', 'name', and 'hasCart', corresponding to the
// properties of the object being converted to JSON.
  Map<String, Object?> toJson(){
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'hasCart': hasCart,
    };
  }
// The function `fromJson` converts a JSON map to a `MyUserEntity` object in Dart.
// 
// Args:
//   json (Map<String, Object?>): The `fromJson` function takes a `Map<String,
// Object?>` named `json` as a parameter. This `json` map is expected to contain
// the following keys:
// 
// Returns:
//   The `MyUserEntity` object is being returned after creating it from the
// provided JSON data. The `userId`, `email`, `name`, and `hasCart` properties are
// extracted from the JSON map and used to initialize the `MyUserEntity` object.
  static MyUserEntity fromJson(Map<String, Object?> json){
    return MyUserEntity(
      userId: json['userId'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      hasCart: json['hasCart'] as bool,
    );
  }
}
