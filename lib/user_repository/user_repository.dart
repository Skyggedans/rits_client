import 'package:meta/meta.dart';

import 'package:oauth2/oauth2.dart' as oauth2;

import '../settings.dart' as settings;

class UserRepository {
  String _accessToken;

  String get accessToken => _accessToken;

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    final client = await oauth2.resourceOwnerPasswordGrant(
        Uri.parse(settings.authEndpoint), username, password,
        identifier: settings.authClientId, secret: settings.authClientSecret);

    return client.credentials.accessToken;
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    _accessToken = null;
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    _accessToken = token;
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return (_accessToken ?? '').isNotEmpty;
  }
}
