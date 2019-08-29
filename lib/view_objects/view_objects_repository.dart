import 'dart:convert';

import 'package:meta/meta.dart';

import '../models/projects/projects.dart';
import '../models/view_objects/view_objects.dart';
import '../settings.dart' as settings;
import '../utils/utils.dart';

class ViewObjectsRepository<T extends ViewObject> {
  final AbstractRestClient restClient;

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
