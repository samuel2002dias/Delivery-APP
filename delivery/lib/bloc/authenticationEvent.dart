part of 'authenticationBloc.dart';

/// The `AuthenticationEvent` class is a sealed class that represents events related to authentication.
/// It extends the `Equatable` class to enable value comparisons.
///
/// The `AuthenticationEvent` class has the following members:
/// - A constructor that initializes the event.
/// - The `props` getter returns an empty list, indicating that there are no properties to be used for value comparisons.
///
/// The `AuthenticationUserChanged` class is a subclass of `AuthenticationEvent` that represents an event
/// where the authenticated user has changed. It has the following members:
/// - `user`: An optional `MyUser` object representing the new authenticated user.
///
/// The `AuthenticationUserChanged` class has the following members:
/// - A constructor that initializes the event with the given user.
/// - The `props` getter returns a list containing the `user` property, enabling value comparisons based on the user.~

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  final MyUser? user;

  const AuthenticationUserChanged(this.user);
}
