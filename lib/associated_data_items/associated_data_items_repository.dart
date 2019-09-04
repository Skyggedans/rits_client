import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:rits_client/models/associated_data/associated_data.dart';
import 'package:rits_client/models/projects/project.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/view_objects/view_objects.dart';

class AssociatedDataItemsRepository
    extends ViewObjectsRepository<BusinessObject> {
  AssociatedDataItemsRepository({@required restClient})
      : super(restClient: restClient);

  @override
  Future<List<BusinessObject>> fetchViewObjects(
    Project project,
    String type,
    String userToken,
  ) async {
    final url = '${settings.backendUrl}/GetAssociatedDataItems/$userToken';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((report) {
      return BusinessObject.fromJson(report);
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
