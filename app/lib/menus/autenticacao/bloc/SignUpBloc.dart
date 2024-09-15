import 'package:app/user/src/models/user.dart';
import 'package:app/user/userClass.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


part 'SignUpEvent.dart';
part 'SignUpState.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;

  SignUpBloc(this._userRepository) : super(SignUpInitial()) {
    on<SignUpRequired>((event, emit) async {
      emit(SignUpProcess());
      try {
        MyUser myUser =
            await _userRepository.signUp(event.user, event.password);
        await _userRepository.setUserData(myUser);
        emit(SignUpSuccess());
      } catch (e) {
        emit(SignUpFailure());
      }
    });
  }
}
