import 'dart:developer'; 
import 'package:delivery/user/src/entities/entities.dart';
import 'package:delivery/user/src/models/user.dart';
import 'package:delivery/user/userClass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final UsersList = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Signs in a user with the provided email and password.
  ///
  /// This method attempts to sign in a user using Firebase Authentication with
  /// the given email and password. If the sign-in process is successful, the
  /// method completes without returning any value. If an error occurs during
  /// the sign-in process, the error is logged and rethrown.
  ///
  /// - Parameters:
  ///   - email: The email address of the user.
  ///   - password: The password for the user.
  ///
  /// - Returns: A `Future` that completes when the sign-in process is finished.
  ///
  /// - Throws: Any exceptions that occur during the sign-in process.
  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  /// Signs up a new user with the provided `MyUser` object and password.
  ///
  /// This method attempts to create a new user with the given email and password
  /// using Firebase Authentication. If the sign-up process is successful, a
  /// `UserCredential` object is returned. If an error occurs during the sign-up
  /// process, the error is logged and rethrown.
  ///
  /// - Parameters:
  ///   - myUser: The `MyUser` object containing the user's information.
  ///   - password: The password for the new user.
  ///
  /// - Returns: A `Future` that resolves to a `MyUser` object representing the
  ///   newly created user.
  ///
  /// - Throws: Any exceptions that occur during the sign-up process.
  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);

      myUser.userId = user.user!.uid;
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  /// Logs out the currently authenticated user.
  ///
  /// This method signs out the current user using Firebase Authentication.
  /// It completes without returning any value. If an error occurs during
  /// the sign-out process, the error is logged and rethrown.
  ///
  /// - Returns: A `Future` that completes when the sign-out process is finished.
  ///
  /// - Throws: Any exceptions that occur during the sign-out process.
  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser user) async {
   try {
      await UsersList
        .doc(user.userId)
        .set(user.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  /// A stream of `MyUser` objects that represents the current authenticated user.
  /// Listen to authentication state changes.
  /// If there is no authenticated user, yield an empty `MyUser` object and yield a `MyUser` object created from the fetched data.
  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if (firebaseUser == null) {
        yield MyUser.empty;
      } else {
        yield await UsersList.doc(firebaseUser.uid).get().then(
            (value) => MyUser.fromEntity(MyUserEntity.fromJson(value.data()!)));
      }
    });
  }
}
