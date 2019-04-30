import 'dart:async';
import 'package:http/http.dart' as http;

import '../user_repository/user_repository.dart';

class RestClient {
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

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer ${userRepository.accessToken}',
      //'Content-Type': 'application/json'
    };
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
