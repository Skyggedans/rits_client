import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/utils/rest_client.dart';

import '../models/associated_data/associated_data.dart';
import '../models/projects/project.dart';
import '../settings.dart' as settings;
import '../view_objects/view_objects.dart';

class AssociatedDataItemsRepository
    extends ViewObjectsRepository<BusinessObject> {
  AssociatedDataItemsRepository({@required RestClient restClient})
      : super(restClient: restClient);

  @override
  Future<List<BusinessObject>> fetchViewObjects(
    Project project,
    String type,
    String userToken,
  ) async {
    final url = '${settings.backendUrl}/GetAssociatedDataItems/$userToken';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((reportJson) {
      return BusinessObject.fromJson(reportJson);
    }).toList();
  }

  @override
  Future<List<BusinessObject>> fetchHierarchyViewObjects(
    Project project,
    String type,
    String hierarchyLevel,
    String userToken,
  ) async {
    return await fetchViewObjects(project, type, userToken);
  }
}
