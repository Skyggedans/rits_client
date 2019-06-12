import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../authentication/authentication.dart';
import '../settings.dart' as settings;

typedef RequestFunc = Future<http.Response> Function(String url,
    {Map<String, String> headers, Map<String, String> body, Encoding encoding});

class ApiError implements Exception {
  final String message;

  ApiError(this.message);

  @override
  String toString() => message;
}

abstract class AbstractRestClient {
  Future<http.Response> get(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final allHeaders = <String, String>{}
      ..addAll(_getHeaders())
      ..addAll(headers);

    final response = await http.get(
      url,
      headers: allHeaders,
    );

    return _handleResponse(response);
  }

  Future<http.Response> post(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final allHeaders = <String, String>{}
      ..addAll(_getHeaders())
      ..addAll(headers);

    final response = await http.post(
      url,
      body: body,
      headers: allHeaders,
      encoding: encoding,
    );

    return _handleResponse(response);
  }

  Future<http.Response> delete(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final allHeaders = <String, String>{}
      ..addAll(_getHeaders())
      ..addAll(headers);

    final response = await http.delete(
      url,
      headers: allHeaders,
    );

    return _handleResponse(response);
  }

  Future<http.Response> put(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final allHeaders = <String, String>{}
      ..addAll(_getHeaders())
      ..addAll(headers);

    final response = await http.put(
      url,
      body: body,
      headers: allHeaders,
      encoding: encoding,
    );

    return _handleResponse(response);
  }

  Map<String, String> _getHeaders();

  http.Response _handleResponse(http.Response response);
}

class RestClient extends AbstractRestClient {
  static RestClient _instance;
  final AuthRepository authRepository;

  RestClient._internal({this.authRepository});

  factory RestClient({AuthRepository authRepository}) {
    if (_instance == null) {
      assert(authRepository != null);
      _instance = RestClient._internal(authRepository: authRepository);
    }

    return _instance;
  }

  @override
  Future<http.Response> get(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final func = _requestWrapper(super.get);

    return await func(url, headers: headers);
  }

  @override
  Future<http.Response> post(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final func = _requestWrapper(super.post);

    return await func(url, headers: headers);
  }

  @override
  Future<http.Response> delete(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final func = _requestWrapper(super.delete);

    return await func(url, headers: headers);
  }

  @override
  Future<http.Response> put(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final func = _requestWrapper(super.put);

    return await func(url, headers: headers);
  }

  RequestFunc _requestWrapper(RequestFunc func) {
    final newFunc = (
      String url, {
      Map<String, String> headers,
      Map<String, String> body,
      Encoding encoding,
    }) async {
      try {
        return await func(url,
            headers: headers, body: body, encoding: encoding);
      } on AccessDeniedError {
        try {
          final tokenResponse = await _requestAccessTokenByRefreshToken(
              authRepository.refreshToken);

          await authRepository.persistTokens(
            tokenResponse['access_token'],
            tokenResponse['refresh_token'],
            DateTime.now().add(
              Duration(seconds: tokenResponse['expires_in']),
            ),
          );

          return await func(url,
              headers: headers, body: body, encoding: encoding);
        } on TokenRevokedError {
          throw AccessDeniedError();
        }
      }
    };

    return newFunc;
  }

  Map<String, String> _getHeaders() {
    return {'Authorization': 'Bearer ${authRepository.accessToken}'};
  }

  http.Response _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode == 401) {
      throw AccessDeniedError();
    } else if (statusCode != 200) {
      throw ApiError('Error while fetching data');
    }

    return response;
  }

  Future<Map<String, dynamic>> _requestAccessTokenByRefreshToken(
      String refreshToken) async {
    final response = await http.post(
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

class LuisClient extends AbstractRestClient {
  static LuisClient _instance;

  LuisClient._internal();

  factory LuisClient() {
    if (_instance == null) {
      _instance = LuisClient._internal();
    }

    return _instance;
  }

  @override
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key': settings.luisConfig['subKeyId'],
    };
  }

  @override
  http.Response _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode != 200) {
      throw ApiError('Error while fetching LUIS data');
    }

    return response;
  }
}
