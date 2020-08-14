import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/utils.dart';

class ViewObjectsRepository<T extends ViewObject> {
  final RestClient restClient;
  final AppContext appContext;

  const ViewObjectsRepository({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null);

  Future<List<T>> fetchViewObjects(String type) async {
    final url =
        '${settings.backendUrl}/ViewObjects/${appContext.userToken}/$type';
    final response = await restClient.get(url);

    final body = List<Map<String, dynamic>>.from(
        (json.decode(response.body) ?? []) as List);

    return body
        .map((reportJson) => ViewObject.fromJson(reportJson))
        .cast<T>()
        .toList();
  }

  Future<List<T>> fetchHierarchyViewObjects(String type) async {
    final url =
        '${settings.backendUrl}/Hierarchy/${appContext.userToken}/${appContext.hierarchyParam}/$type';

    final response = await restClient.get(url);

    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((report) => ViewObject.fromJson(report)).cast<T>().toList();
  }

  Future<List<T>> fetchFavoriteViewObjects(String type) async {
    final url =
        '${settings.backendUrl}/GetUserReportsForType/${appContext.userToken}/$type';
    final response = await restClient.get(url);

    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List)
            .map((itemJson) {
      return {
        'Name': itemJson['ViewName'],
        'Title': itemJson['Title'],
        'ContentTypeName': itemJson['ContentTypeName'],
        'ItemTypeName': itemJson['ViewType'],
        'HierarchyLevel': itemJson['LevelNumber'],
      };
    });

    return body.map((report) => ViewObject.fromJson(report)).cast<T>().toList();
  }
}
