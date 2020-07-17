import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  AuthState([List props = const []]) : super(props);
}

class AuthUninitialized extends AuthState {
  @override
  String toString() => 'AuthUninitialized';
}

class AuthReinitialized extends AuthState {
  @override
  String toString() => 'AuthReinitialized';
}

class AuthPending extends AuthState {
  final String userCode;
  final String verificationUrl;
  final Duration expiresIn;

  AuthPending({this.userCode, this.verificationUrl, this.expiresIn})
      : super([userCode, verificationUrl]);

  @override
  String toString() => 'AuthPending';
}

class AuthFailed extends AuthState {
  final String reason;

  AuthFailed({this.reason}) : super([reason]);

  @override
  String toString() => 'AuthFailed { reason: $reason}';
}

class Authenticated extends AuthState {
  @override
  String toString() => 'Authenticated';
}

class Unauthenticated extends AuthState {
  @override
  String toString() => 'Unauthenticated';
}

class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}
