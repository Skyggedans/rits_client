import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/associated_data/associated_data.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_objects/view_objects.dart';

class AssociatedDataItemsRepository
    extends ViewObjectsRepository<BusinessObject> {
  AssociatedDataItemsRepository({
    @required RestClient restClient,
    @required AppContext appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super(restClient: restClient, appContext: appContext);

  @override
  Future<List<BusinessObject>> fetchViewObjects(String type) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataItems/${appContext.userToken}';

    final response = await restClient.get(url);

    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((reportJson) {
      return BusinessObject.fromJson(reportJson);
    }).toList();
  }

  @override
  Future<List<BusinessObject>> fetchHierarchyViewObjects(String type) async {
    return await fetchViewObjects(type);
  }
}
