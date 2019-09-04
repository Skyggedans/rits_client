import 'package:get_it/get_it.dart';

import 'authentication.dart';

class AuthRepository {
  final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  String _accessToken;
  String _refreshToken;
  DateTime _expiresAt;

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  DateTime get expiresAt => _expiresAt;

  // AuthRepository({@required authProvider})
  //     : this.authProvider = authProvider ?? GetIt.instance<AuthProvider>(),
  //       assert(authProvider != null);

  Future<void> _getTokens() async {
    final auth = await _authProvider.getAuth();

    if (auth != null) {
      _accessToken = auth['access_token'];
      _refreshToken = auth['refresh_token'];
      _expiresAt = DateTime.fromMillisecondsSinceEpoch(auth['expires_at']);
    }
  }

  Future<void> persistTokens(
      String accessToken, String refreshToken, DateTime expiresAt) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = expiresAt;

    await _authProvider.saveAuth({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.millisecondsSinceEpoch,
    });
  }

  Future<void> deleteTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;

    await _authProvider.deleteAuth();
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
