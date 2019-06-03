import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as HttpClient;
import 'package:oauth2/oauth2.dart';

import '../settings.dart' as settings;
import '../user_repository/user_repository.dart';
import './authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository}) {
    assert(userRepository != null);
  }

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      if (await userRepository.hasToken()) {
        yield Authenticated();
      } else if (await userRepository.hasRefreshToken()) {
        try {
          final response = await _requestAccessTokenByRefreshToken(
              userRepository.refreshToken);

          await userRepository.persistTokens(
            accessToken: response['access_token'],
            expiresAt: DateTime.now().add(
              Duration(seconds: response['expires_in']),
            ),
          );

          yield Authenticated();
        } on TokenRevokedError {
          dispatch(Authenticate());
        } on TokenExpiredError {
          dispatch(Authenticate());
        }
      } else {
        dispatch(Authenticate());
      }
    } else if (event is Authenticate) {
      try {
        final response = await _requestUserAndDeviceCodes();

        print(
            'Authentication backend will be waiting for user code for ${response['expires_in']} seconds');

        yield AuthenticationPending(
          userCode: response['user_code'],
          verificationUrl: response['verification_url'],
        );

        final pollingExpiresAt =
            DateTime.now().add(Duration(seconds: response['expires_in']));

        Timer.periodic(
          Duration(milliseconds: response['interval'] * 1000 + 100),
          (timer) async {
            try {
              print('Requesting access token');

              final tokenResponse =
                  await _requestAccessToken(response['device_code']);

              timer.cancel();

              print('Access granted');

              dispatch(AccessGranted(
                  accessToken: tokenResponse['access_token'],
                  refreshToken: tokenResponse['refresh_token'],
                  expiresAt: DateTime.now()
                      .add(Duration(seconds: tokenResponse['expires_in']))));
            } on AuthorizationPendingError catch (e) {
              print(e);
            } on RateLimitExceededError catch (e) {
              print(e);
            } on TokenExpiredError catch (e) {
              print(e);
              dispatch(Authenticate());
            } on AuthorizationException catch (e) {
              dispatch(AccessDenied(reason: e.toString()));
            }

            if (DateTime.now().isAfter(pollingExpiresAt)) {
              timer.cancel();
              print('Token aquisition expired');
              dispatch(Authenticate());
            }
          },
        );
      } on RateLimitExceededError catch (e) {
        print(e);

        Future.delayed(const Duration(seconds: 1), () {
          dispatch(Authenticate());
        });
      }
    } else if (event is AccessGranted) {
      await userRepository.persistTokens(
        accessToken: event.accessToken,
        refreshToken: event.refreshToken,
        expiresAt: event.expiresAt,
      );

      yield Authenticated();
    } else if (event is AccessDenied) {
      yield AuthenticationFailed(reason: event.reason);
    } else if (event is AccessRevoked) {
      await userRepository.deleteTokens();
      yield Unauthenticated();
    } else if (event is AccessTokenExpired) {
      yield Unauthenticated();
    }
  }

  Future<Map<String, dynamic>> _requestUserAndDeviceCodes() async {
    final response = await HttpClient.post(
      settings.authUrl,
      body: {
        'client_id': settings.authClientId,
        'scope': 'profile',
      },
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return body;
    } else if (response.statusCode == 401 && body['error'] == 'access_denied') {
      throw AccessDeniedError();
    } else if (response.statusCode == 403 &&
        body['error_code'] == 'rate_limit_exceeded') {
      throw RateLimitExceededError();
    }
  }

  Future<Map<String, dynamic>> _requestAccessToken(String deviceCode) async {
    final response = await HttpClient.post(
      settings.authTokenUrl,
      body: {
        'client_id': settings.authClientId,
        'client_secret': settings.authClientSecret,
        'code': deviceCode,
        'grant_type': 'http://oauth.net/grant_type/device/1.0'
      },
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return body;
    } else if (response.statusCode == 400) {
      if (body['error'] == 'authorization_pending') {
        throw AuthorizationPendingError();
      } else if (body['error'] == 'invalid_grant') {
        throw InvalidUserCodeError();
      } else if (body['error'] == 'invalid_request') {
        throw InvalidRequestError();
      } else if (body['error'] == 'unsupported_grant_type') {
        throw InvalidGrantTypeError();
      } else if (body['error'] == 'slow_down') {
        throw RateLimitExceededError();
      } else if (body['error'] == 'token_expired') {
        throw TokenExpiredError();
      }
    } else if (response.statusCode == 403 && body['error'] == 'access_denied') {
      throw AccessDeniedError();
    } else if (response.statusCode == 429 && body['error'] == 'slow_down') {
      throw RateLimitExceededError();
    }

    response;
  }

  Future<Map<String, dynamic>> _requestAccessTokenByRefreshToken(
      String refreshToken) async {
    final response = await HttpClient.post(
      settings.authUrl,
      body: {
        'client_id': settings.authClientId,
        'client_secret': settings.authClientSecret,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token'
      },
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return body;
    } else {
      throw TokenRevokedError();
    }
  }
}
