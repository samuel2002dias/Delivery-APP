// The `MyUser` class in Dart represents a user with properties such as userId,
// email, name, and a boolean flag indicating if the user has a cart.
import 'package:delivery/user/src/entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  bool hasCart;
  String role;
  String phone;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasCart,
    required this.role,
    required this.phone,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    hasCart: false,
    role: 'Client',
    phone: '',
  );

// Transform the Myuser object into json map. The json file will be "uploaded" into the firebase (database)
// The `toEntity` function converts a `MyUserEntity` object to a `MyUserEntity`
// object.
//
// Returns:
// - An instance of `MyUserEntity` is being returned with the properties `userId`, `email`, `name`, and `hasCart`
// set to the corresponding values of the current object.
  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      hasCart: hasCart,
      role: role,
      phone: phone,
    );
  }

// Transform the json map into Myuser object. The json file will be "downloaded" from the firebase (database)
// The function `fromEntity` converts a `MyUserEntity` object to a `MyUser` object
// in Dart.
//
// Args:
//   entity (MyUserEntity): The `fromEntity` method takes a `MyUserEntity` object
// as a parameter and creates a `MyUser` object using the data from the entity. The
// `MyUserEntity` object likely contains properties such as `userId`, `email`,
// `name`, and `hasCart`. The method
//
// Returns:
//   An instance of the `MyUser` class is being returned, with properties
// initialized using values from the `MyUserEntity` object passed as a parameter.
  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      hasCart: entity.hasCart,
      role: entity.role,
      phone: entity.phone,
    );
  }

  @override
  String toString() {
    return 'MyUser{userId: $userId, email: $email, name: $name, hasCart: $hasCart, role: $role, phone: $phone}';
  }
}
