import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../authentication/authentication.dart';
import '../settings.dart' as settings;
import 'utils.dart';

typedef RequestFunc = Future<http.Response> Function(String url,
    {Map<String, String> headers});

typedef BodiedRequestFunc = Future<http.Response> Function(String url,
    {Map<String, String> headers, dynamic body, Encoding encoding});

abstract class AbstractRestClient {
  Future<http.Response> get(String url,
      {Map<String, String> headers: const {}}) async {
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
      {Map<String, String> headers: const {}}) async {
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

  http.BaseResponse _handleResponse(http.BaseResponse response);
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
      {Map<String, String> headers: const {}}) async {
    final RequestFunc func = _requestWrapper(super.get);

    return await func(url, headers: headers);
  }

  @override
  Future<http.Response> post(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final BodiedRequestFunc func = _requestWrapper(super.post);

    return await func(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<http.Response> delete(String url,
      {Map<String, String> headers: const {}}) async {
    final RequestFunc func = _requestWrapper(super.delete);

    return await func(url, headers: headers);
  }

  @override
  Future<http.Response> put(String url,
      {Map<String, String> headers: const {}, body, encoding}) async {
    final BodiedRequestFunc func = _requestWrapper(super.put);

    return await func(url, headers: headers, body: body, encoding: encoding);
  }

  Future<http.StreamedResponse> uploadFile(
    String url, {
    Map<String, String> headers: const {},
    String field,
    String filePath,
    String fileName,
    Uint8List bytes,
    MediaType contentType,
  }) async {
    final allHeaders = <String, String>{}
      ..addAll(_getHeaders())
      ..addAll(headers);

    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(allHeaders);

    http.MultipartFile file;

    if (filePath != null) {
      file = await http.MultipartFile.fromPath(
        field,
        filePath,
        contentType: contentType,
      );
    } else if (bytes != null) {
      file = http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: fileName,
        contentType: contentType,
      );
    }

    if (file != null) {
      request.files.add(file);
    }

    try {
      return _handleResponse(await request.send());
    } on AccessDeniedError {
      try {
        await _tryRefreshToken();

        return _handleResponse(await request.send());
      } on TokenRevokedError {
        throw AccessDeniedError();
      }
    }
  }

  Function _requestWrapper(Function func) {
    final newFunc = (
      String url, {
      Map<String, String> headers,
      dynamic body,
      Encoding encoding,
    }) async {
      assert(func is RequestFunc || func is BodiedRequestFunc);

      invokeRequest() async {
        if (func is BodiedRequestFunc) {
          return await func(
            url,
            headers: headers,
            body: body,
            encoding: encoding,
          );
        } else if (func is RequestFunc) {
          return await func(url, headers: headers);
        }

        return null;
      }

      try {
        return await invokeRequest();
      } on AccessDeniedError {
        try {
          await _tryRefreshToken();

          return await invokeRequest();
        } on TokenRevokedError {
          throw AccessDeniedError();
        }
      }
    };

    return newFunc;
  }

  Future<void> _tryRefreshToken() async {
    final tokenResponse =
        await _requestAccessTokenByRefreshToken(authRepository.refreshToken);

    return await authRepository.persistTokens(
      tokenResponse['access_token'],
      tokenResponse['refresh_token'],
      DateTime.now().add(
        Duration(seconds: tokenResponse['expires_in']),
      ),
    );
  }

  Map<String, String> _getHeaders() {
    return {'Authorization': 'Bearer ${authRepository.accessToken}'};
  }

  http.BaseResponse _handleResponse(http.BaseResponse response) {
    final int statusCode = response.statusCode;

    if (statusCode == 401) {
      throw AccessDeniedError();
    } else if (statusCode < 200 || statusCode >= 300) {
      throw ApiError('Error while fetching data');
    }

    return response;
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
  http.BaseResponse _handleResponse(http.BaseResponse response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode >= 300) {
      throw ApiError('Error while fetching LUIS data');
    }

    return response;
  }
}
