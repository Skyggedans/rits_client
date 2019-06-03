import 'package:meta/meta.dart';

import 'package:oauth2/oauth2.dart' as oauth2;

import '../settings.dart' as settings;

class UserRepository {
  String _accessToken;
  String _refreshToken;
  DateTime _expiresAt;

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    final client = await oauth2.resourceOwnerPasswordGrant(
        Uri.parse(settings.authUrl), username, password,
        identifier: settings.authClientId, secret: settings.authClientSecret);

    return client.credentials.accessToken;
  }

  Future<void> deleteTokens() async {
    /// delete from keystore/keychain
    _accessToken = null;
    _refreshToken = null;
    _expiresAt = null;

    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistTokens(
      {String accessToken, String refreshToken, DateTime expiresAt}) async {
    /// write to keystore/keychain
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresAt = expiresAt;

    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return (_accessToken ?? '').isNotEmpty &&
        _expiresAt.isAfter(DateTime.now());
  }

  Future<bool> hasRefreshToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return (_refreshToken ?? '').isNotEmpty;
  }
}
