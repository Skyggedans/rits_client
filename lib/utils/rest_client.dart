import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

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

  Future<http.Response> get(String url, {Map<String, String> headers}) async {
    final allHeaders =
        CombinedMapView(<Map<String, String>>[getHeaders(), headers]);
    final response = await http.get(url, headers: getHeaders());

    return handleResponse(response);
  }

  Future<http.Response> post(String url,
      {Map<String, String> headers, body, encoding}) async {
    final allHeaders =
        CombinedMapView(<Map<String, String>>[getHeaders(), headers]);
    final response = await http.post(url,
        body: body, headers: allHeaders, encoding: encoding);

    return handleResponse(response);
  }

  Future<http.Response> delete(String url,
      {Map<String, String> headers}) async {
    final allHeaders =
        CombinedMapView(<Map<String, String>>[getHeaders(), headers]);
    final response = await http.delete(url, headers: allHeaders);

    return handleResponse(response);
  }

  Future<http.Response> put(String url,
      {Map<String, String> headers, body, encoding}) async {
    final allHeaders =
        CombinedMapView(<Map<String, String>>[getHeaders(), headers]);
    final response = await http.put(url,
        body: body, headers: allHeaders, encoding: encoding);

    return handleResponse(response);
  }

  Map<String, String> getHeaders() {
    return {
      'Authorization': 'Bearer ${userRepository.accessToken}',
      'Content-Type': 'application/json'
    };
  }

  http.Response handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode == 401) {
      throw new Exception('Unauthorized');
    }
    else if (statusCode != 200) {
      throw new Exception('Error while fetching data');
    }

    return response;
  }
}
