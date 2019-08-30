import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rits_client/models/models.dart';
import 'package:rits_client/utils/rest_client.dart';

class ProjectsDao {
  final AbstractRestClient restClient;
  final AppConfig appConfig;

  ProjectsDao({
    @required this.restClient,
    @required this.appConfig,
  })  : assert(restClient != null),
        assert(appConfig != null);

  Future<List<Project>> getProjects() async {
    final url = '${appConfig.settings.backendUrl}/GetProjects';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((param) {
      return Project.fromJson(param);
    }).toList();
  }
}
