import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../user/src/models/models.dart';
import '../user/user_repository.dart';

part 'authenticationEvent.dart';
part 'authenticationState.dart';

/// The `AuthenticationBloc` class is responsible for managing the authentication state of the application.
/// It extends the `Bloc` class from the `flutter_bloc` package, handling `AuthenticationEvent` events and
/// emitting `AuthenticationState` states.
///
/// The `AuthenticationBloc` class has the following members:
/// - `userRepository`: A repository that provides user-related data and operations.
/// - `_userSubscription`: A subscription to the user stream provided by the `userRepository`.
///
/// The constructor initializes the bloc with an unknown authentication state and sets up a listener on the
/// user stream from the `userRepository`. When the user stream emits a new user, an `AuthenticationUserChanged`
/// event is added to the bloc.
///
/// The `on<AuthenticationUserChanged>` method handles `AuthenticationUserChanged` events. If the event's user
/// is not empty, it emits an authenticated state with the user. Otherwise, it emits an unauthenticated state.
///
/// The `close` method cancels the user subscription and then calls the `super.close` method to close the bloc.
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubscription;

  AuthenticationBloc({required this.userRepository})
      : super(const AuthenticationState.unknown()) {
    _userSubscription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user));
    });

    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
