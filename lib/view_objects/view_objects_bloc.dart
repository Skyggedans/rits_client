import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/view_objects/view_objects.dart';
import '../models/projects/projects.dart';
import 'view_objects.dart';

class ViewObjectsBloc extends Bloc<ViewObjectsEvent, ViewObjectsState> {
  final RestClient restClient;

  ViewObjectsBloc({@required this.restClient});

  @override
  Stream<ViewObjectsEvent> transform(Stream<ViewObjectsEvent> events) {
    return (events as Observable<ViewObjectsEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => ViewObjectsUninitialized();

  @override
  Stream<ViewObjectsState> mapEventToState(ViewObjectsEvent event) async* {
    if (event is FetchViewObjects) {
      try {
        if (currentState is ViewObjectsUninitialized) {
          final reports = event.hierarchyLevel?.isNotEmpty == true
              ? await _fetchHierarchyViewObjects(
                  event.project,
                  event.type,
                  event.hierarchyLevel,
                  event.userToken,
                )
              : await _fetchViewObjects(
                  event.project,
                  event.type,
                  event.userToken,
                );

          yield ViewObjectsLoaded(
              viewObjects: reports, userToken: event.userToken);
        }
      } catch (_) {
        yield ViewObjectsError();
      }
    }
  }

  Future<List<ViewObject>> _fetchViewObjects(
    Project project,
    String type,
    String userToken,
  ) async {
    final url = '${settings.backendUrl}/ViewObjects/$userToken/${type}';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((report) {
      return ViewObject.fromJson(report);
    }).toList();
  }

  Future<List<ViewObject>> _fetchHierarchyViewObjects(
    Project project,
    String type,
    String hierarchyLevel,
    String userToken,
  ) async {
    final url =
        '${settings.backendUrl}/Hierarchy/$userToken/$hierarchyLevel/${type}';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((report) {
      return ViewObject.fromJson(report);
    }).toList();
  }
}
