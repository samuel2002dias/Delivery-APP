import 'package:webapp/user/userClass.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'LogInEvent.dart';
part 'LogInState.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc(this._userRepository) : super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: event.email, password: event.password);

        bool isAdminUser = await isAdmin(userCredential.user!.uid);
        if (isAdminUser) {
          emit(SignInSuccess());
        } else {
          emit(SignInFailure());
        }
      } catch (e) {
        emit(SignInFailure());
      }
    });

    on<SignOutRequired>((event, emit) async {
      await _userRepository.logOut();
      emit(SignOutSuccess());
    });
  }

  Future<bool> isAdmin(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      String role = userDoc['role'];
      return role == 'Admin' || role == 'Delivery Guy';
    }
    return false;
  }
}
