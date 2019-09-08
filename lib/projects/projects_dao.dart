import 'dart:convert';

import 'package:rits_client/locator.dart';
import 'package:rits_client/models/models.dart';
import 'package:rits_client/utils/rest_client.dart';

class ProjectsDao {
  final restClient = locator<RestClient>();
  final appConfig = locator<AppConfig>();

  Future<List<Project>> getProjects() async {
    final url = '${appConfig.settings.backendUrl}/GetProjects';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((param) {
      return Project.fromJson(param);
    }).toList();
  }
}
