// ignore_for_file: file_names

part of 'authenticationBloc.dart';

/// The `AuthenticationState` class represents the authentication state of the application.
/// It extends the `Equatable` class to enable value comparisons.
///
/// The `AuthenticationState` class has the following members:
/// - `status`: An `AuthenticationStatus` enum value indicating the current authentication status.
/// - `user`: An optional `MyUser` object representing the authenticated user, if any.
///
/// The `AuthenticationState` class provides three named constructors:
/// - `AuthenticationState.unknown()`: Creates an authentication state with an unknown status.
/// - `AuthenticationState.authenticated(MyUser myUser)`: Creates an authentication state with an authenticated status and the given user.
/// - `AuthenticationState.unauthenticated()`: Creates an authentication state with an unauthenticated status.
///
/// The `props` getter returns a list of properties to be used for value comparisons, including the `status` and `user`.
enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationState extends Equatable {
  const AuthenticationState._(
      {this.status = AuthenticationStatus.unknown, this.user});

  final AuthenticationStatus status;
  final MyUser? user;

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(MyUser myUser)
      : this._(status: AuthenticationStatus.authenticated, user: myUser);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}