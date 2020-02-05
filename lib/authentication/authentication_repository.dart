import 'package:meta/meta.dart';

import 'authentication.dart';

class AuthRepository {
  final AuthProvider authProvider;

  String _accessToken;
  String _refreshToken;
  DateTime _expiresAt;

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  DateTime get expiresAt => _expiresAt;

  AuthRepository({@required this.authProvider}) : assert(authProvider != null);

  Future<void> _getTokens() async {
    final auth = await authProvider.getAuth();

    if (auth != null) {
      _accessToken = auth['access_token'] as String;
      _refreshToken = auth['refresh_token'] as String;
      _expiresAt =
          DateTime.fromMillisecondsSinceEpoch(auth['expires_at'] as int);
    }
  }

  Future<void> persistTokens(
      String accessToken, String refreshToken, DateTime expiresAt) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = expiresAt;

    await authProvider.saveAuth({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.millisecondsSinceEpoch,
    });
  }

  Future<void> deleteTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;

    await authProvider.deleteAuth();
  }

  Future<bool> hasAccessToken() async {
    if (_accessToken == null) {
      await _getTokens();
    }

    return (_accessToken ?? '').isNotEmpty &&
        _expiresAt.isAfter(DateTime.now());
  }

  Future<bool> hasRefreshToken() async {
    if (_refreshToken == null) {
      await _getTokens();
    }

    return (_refreshToken ?? '').isNotEmpty;
  }
}
