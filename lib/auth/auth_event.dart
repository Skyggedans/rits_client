import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  AuthEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthEvent {
  @override
  String toString() => 'AppStarted';
}

class Authenticate extends AuthEvent {
  @override
  String toString() => 'Authenticate';
}

class AccessGranted extends AuthEvent {
  @override
  String toString() => 'AccessGranted';
}

class AccessDenied extends AuthEvent {
  final String reason;

  AccessDenied({@required this.reason}) : super();

  @override
  String toString() => 'AccessDenied { reason: $reason }';
}

class LoggedIn extends AuthEvent {
  final String token;

  LoggedIn({@required this.token}) : super([token]);

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthEvent {
  @override
  String toString() => 'LoggedOut';
}

class AccessRevoked extends AuthEvent {
  @override
  String toString() => 'AccessRevoked';
}

class AccessTokenExpired extends AuthEvent {
  @override
  String toString() => 'AccessTokenExpired';
}
