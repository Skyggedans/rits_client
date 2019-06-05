import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  Auth({this.accessToken, this.refreshToken, this.expiresAt})
      : super([accessToken, refreshToken, expiresAt]);

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresAt: json['expires_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt,
      };
}
