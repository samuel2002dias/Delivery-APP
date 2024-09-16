import 'package:delivery/user/userClass.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';


part 'LogInEvent.dart';
part 'LogInState.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc(this._userRepository) : super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        await _userRepository.signIn(event.email, event.password);
      } catch (e) {
        emit(SignInFailure());
      }
    });

    on<SignOutRequired>((event, emit) async => await _userRepository.logOut());
  }
}
