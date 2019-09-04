import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/utils.dart';

class ViewObjectsRepository<T extends ViewObject> {
  final RestClient restClient;

  const ViewObjectsRepository({@required this.restClient})
      : assert(restClient != null);

  Future<List<T>> fetchViewObjects(
    Project project,
    String type,
    String userToken,
  ) async {
    final url = '${settings.backendUrl}/ViewObjects/$userToken/$type';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((report) {
      return ViewObject.fromJson(report);
    }).toList();
  }

  Future<List<T>> fetchHierarchyViewObjects(
    Project project,
    String type,
    String hierarchyLevel,
    String userToken,
  ) async {
    final url =
        '${settings.backendUrl}/Hierarchy/$userToken/$hierarchyLevel/$type';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((report) {
      return ViewObject.fromJson(report);
    }).toList();
  }
}
