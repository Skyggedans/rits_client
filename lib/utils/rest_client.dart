import 'dart:async';
import 'package:http/http.dart' as http;

import '../user_repository/user_repository.dart';
import '../settings.dart' as settings;

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

  http.Response _handleResponse(http.Response response);
}

class RestClient extends AbstractRestClient {
  static RestClient _instance;
  final UserRepository userRepository;

  RestClient._internal({this.userRepository});

  factory RestClient({UserRepository userRepository}) {
    if (_instance == null) {
      assert(userRepository != null);
      _instance = RestClient._internal(userRepository: userRepository);
    }

    return _instance;
  }

  Map<String, String> _getHeaders() {
    return {'Authorization': 'Bearer ${userRepository.accessToken}'};
  }

  http.Response _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode == 401) {
      throw new Exception('Unauthorized');
    } else if (statusCode != 200) {
      throw new Exception('Error while fetching data');
    }

    return response;
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
      throw new Exception('Error while fetching LUIS data');
    }

    return response;
  }
}
