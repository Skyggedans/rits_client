import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';
}

class Authenticate extends AuthenticationEvent {
  @override
  String toString() => 'Authenticate';
}

class AccessGranted extends AuthenticationEvent {
  @override
  String toString() => 'AccessGranted';
}

class AccessDenied extends AuthenticationEvent {
  final String reason;

  AccessDenied({@required this.reason}) : super();

  @override
  String toString() => 'AccessDenied { reason: $reason }';
}

class LoggedIn extends AuthenticationEvent {
  final String token;

  LoggedIn({@required this.token}) : super([token]);

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';
}

class AccessRevoked extends AuthenticationEvent {
  @override
  String toString() => 'AccessRevoked';
}

class AccessTokenExpired extends AuthenticationEvent {
  @override
  String toString() => 'AccessTokenExpired';
}
