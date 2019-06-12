import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const []]) : super(props);
}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  String toString() => 'AuthenticationUninitialized';
}

class AuthenticationPending extends AuthenticationState {
  final String userCode;
  final String verificationUrl;
  final Duration expiresIn;

  AuthenticationPending({this.userCode, this.verificationUrl, this.expiresIn})
      : super([userCode, verificationUrl]);

  @override
  String toString() => 'AuthenticationPending';
}

class AuthenticationFailed extends AuthenticationState {
  final String reason;

  AuthenticationFailed({this.reason}) : super([reason]);

  @override
  String toString() => 'AuthenticationFailed { reason: $reason}';
}

class Authenticated extends AuthenticationState {
  @override
  String toString() => 'AuthenticationAuthenticated';
}

class Unauthenticated extends AuthenticationState {
  @override
  String toString() => 'AuthenticationUnauthenticated';
}

class AuthenticationLoading extends AuthenticationState {
  @override
  String toString() => 'AuthenticationLoading';
}
