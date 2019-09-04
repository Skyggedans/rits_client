import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';

import 'package:rits_client/settings.dart' as settings;
import 'authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStarted();
    } else if (event is Authenticate) {
      yield* _mapAuthenticate();
    } else if (event is AccessGranted) {
      yield Authenticated();
    } else if (event is AccessDenied) {
      yield AuthenticationFailed(reason: event.reason);
      /*}
    else if (event is AccessRevoked) {
      await authRepository.deleteTokens();
      yield Unauthenticated();*/
    } else if (event is AccessTokenExpired) {
      dispatch(Authenticate());
    }
  }

  Stream<AuthenticationState> _mapAppStarted() async* {
    if (await _authRepository.hasAccessToken()) {
      yield Authenticated();
      // } else if (await authRepository.hasRefreshToken()) {
      //   try {
      //     final response = await _requestAccessTokenByRefreshToken(
      //         authRepository.refreshToken);

      //     await authRepository.persistTokens(
      //       response['access_token'],
      //       authRepository.refreshToken,
      //       DateTime.now().add(
      //         Duration(seconds: response['expires_in']),
      //       ),
      //     );

      //     yield Authenticated();
      //   } on TokenRevokedError {
      //     await authRepository.deleteTokens();
      //     dispatch(Authenticate());
      //   } on TokenExpiredError {
      //     await authRepository.deleteTokens();
      //     dispatch(Authenticate());
      //   }
    } else {
      dispatch(Authenticate());
    }
  }

  Stream<AuthenticationState> _mapAuthenticate() async* {
    try {
      final response = await _requestUserAndDeviceCodes();

      print(
          'Authentication backend will be waiting for user code for ${response['expires_in']} seconds');

      yield AuthenticationPending(
        userCode: response['user_code'],
        verificationUrl: response['verification_uri'],
        expiresIn: Duration(seconds: response['expires_in']),
      );

      final stopPollingAt = DateTime.now().add(
        Duration(seconds: response['expires_in']),
      );

      Timer.periodic(
        Duration(milliseconds: response['interval'] * 1000 + 100),
        (timer) async {
          try {
            print('Requesting access token');

            final tokenResponse =
                await _requestAccessToken(response['device_code']);

            timer.cancel();
            print('Access granted for ${tokenResponse['expires_in']} seconds');

            await _authRepository.persistTokens(
              tokenResponse['access_token'],
              tokenResponse['refresh_token'],
              DateTime.now().add(
                Duration(seconds: tokenResponse['expires_in']),
              ),
            );

            dispatch(AccessGranted());
          } on AuthorizationPendingError catch (e) {
            print(e);
          } on RateLimitExceededError catch (e) {
            print(e);
            // sleep(const Duration(seconds: 1));
          } on TokenExpiredError catch (e) {
            timer.cancel();
            print(e);
            //dispatch(Authenticate());
            dispatch(AccessDenied(reason: e.toString()));
          } on AuthorizationException catch (e) {
            timer.cancel();
            print(e);
            dispatch(AccessDenied(reason: e.toString()));
          }

          if (timer.isActive && DateTime.now().isAfter(stopPollingAt)) {
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
  }

  Future<Map<String, dynamic>> _requestUserAndDeviceCodes() async {
    final response = await http.post(
      settings.authUrl,
      body: {
        'client_id': settings.authClientId,
        'scope': 'apiclient offline_access',
      },
    );

    final body = json.decode(response.body);

    if (response.statusCode == 401 && body['error'] == 'access_denied') {
      throw AccessDeniedError();
    } else if (response.statusCode == 403 &&
        body['error_code'] == 'rate_limit_exceeded') {
      throw RateLimitExceededError();
    }

    return body;
  }

  Future<Map<String, dynamic>> _requestAccessToken(String deviceCode) async {
    final response = await http.post(
      settings.authTokenUrl,
      body: {
        'client_id': settings.authClientId,
        'client_secret': settings.authClientSecret,
        'scope': 'apiclient',
        'device_code': deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code'
      },
    );

    final body = json.decode(response.body);

    if (response.statusCode == 400) {
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
      } else if (body['error'] == 'expired_token') {
        throw TokenExpiredError();
      }
    } else if (response.statusCode == 403 && body['error'] == 'access_denied') {
      throw AccessDeniedError();
    } else if (response.statusCode == 429 && body['error'] == 'slow_down') {
      throw RateLimitExceededError();
    }

    return body;
  }

  Future<Map<String, dynamic>> _requestAccessTokenByRefreshToken(
      String refreshToken) async {
    final response = await http.post(
      settings.authTokenUrl,
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
