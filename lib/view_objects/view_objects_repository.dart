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

    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body
        .map((reportJson) => ViewObject.fromJson(reportJson))
        .cast<T>()
        .toList();
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

    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((report) => ViewObject.fromJson(report)).cast<T>().toList();
  }

  Future<List<T>> fetchFavoriteViewObjects(
    Project project,
    String type,
    String userToken,
  ) async {
    final url = '${settings.backendUrl}/GetUserReportsForType/$userToken/$type';
    //final response = await restClient.get(url);

    final body = List<Map<String, dynamic>>.from(json.decode(
                '[{"UserReportID":238,"ViewName":"GetCustomersOrder","Title":"Customer Orders","ContentTypeName":"rdlc","LevelNumber":2,"LevelName":"Company","ViewType":"Reports","Alias":null},{"UserReportID":280,"ViewName":"northwind_demo","Title":"northwind_demo","ContentTypeName":"dot","LevelNumber":0,"LevelName":null,"ViewType":"Reports","Alias":null}]')
            as List)
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
