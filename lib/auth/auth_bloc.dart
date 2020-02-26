import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart';
import 'package:rits_client/settings.dart' as settings;

import 'auth.dart';

final _logger = Logger('auth');

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({@required this.authRepository}) {
    assert(authRepository != null);
  }

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStarted();
    } else if (event is Authenticate) {
      yield* _mapAuthenticate();
    } else if (event is AccessGranted) {
      yield Authenticated();
    } else if (event is AccessDenied) {
      yield AuthFailed(reason: event.reason);
      /*}
    else if (event is AccessRevoked) {
      await authRepository.deleteTokens();
      yield Unauthenticated();*/
    } else if (event is AccessTokenExpired) {
      add(Authenticate());
    }
  }

  Stream<AuthState> _mapAppStarted() async* {
    if (await authRepository.hasAccessToken()) {
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
      add(Authenticate());
    }
  }

  Stream<AuthState> _mapAuthenticate() async* {
    try {
      final response = await _requestUserAndDeviceCodes();

      _logger.info(
          'Authentication will await for user code for ${response['expires_in']} seconds');

      yield AuthPending(
        userCode: response['user_code'] as String,
        verificationUrl: response['verification_uri'] as String,
        expiresIn: Duration(seconds: response['expires_in'] as int),
      );

      final stopPollingAt = DateTime.now().add(
        Duration(seconds: response['expires_in'] as int),
      );

      Timer.periodic(
        Duration(milliseconds: (response['interval'] as int) * 1000 + 100),
        (timer) async {
          try {
            _logger.info('Requesting access token');

            final tokenResponse =
                await _requestAccessToken(response['device_code'] as String);

            timer.cancel();
            _logger.info(
                'Access granted for ${tokenResponse['expires_in']} seconds');

            await authRepository.persistTokens(
              tokenResponse['access_token'] as String,
              tokenResponse['refresh_token'] as String,
              DateTime.now().add(
                Duration(seconds: tokenResponse['expires_in'] as int),
              ),
            );

            add(AccessGranted());
          } on AuthorizationPendingError catch (e) {
            _logger.info(e);
          } on RateLimitExceededError catch (e) {
            _logger.info(e);
          } on TokenExpiredError catch (e) {
            timer.cancel();
            _logger.info(e);
            //dispatch(Authenticate());
            add(AccessDenied(reason: e.toString()));
          } on AuthorizationException catch (e) {
            timer.cancel();
            _logger.info(e);
            add(AccessDenied(reason: e.toString()));
          }

          if (timer.isActive && DateTime.now().isAfter(stopPollingAt)) {
            timer.cancel();
            _logger.info('Token aquisition expired');
            add(Authenticate());
          }
        },
      );
    } on RateLimitExceededError catch (e) {
      _logger.info(e);

      Future.delayed(const Duration(seconds: 1), () {
        add(Authenticate());
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

    final body = json.decode(response.body) as Map<String, dynamic>;

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

    final body = json.decode(response.body) as Map<String, dynamic>;

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

    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    } else {
      throw TokenRevokedError();
    }
  }
}
