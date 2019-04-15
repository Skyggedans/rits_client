import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:android_intent/android_intent.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/projects/projects.dart';
import 'project.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final RestClient restClient;
  static const MethodChannel _channel = MethodChannel('com.rockwellits.client');

  ProjectBloc({@required this.restClient});

  @override
  get initialState => ProjectUninitialized();

  @override
  Stream<ProjectEvent> transform(Stream<ProjectEvent> events) {
    return (events as Observable<ProjectEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<ProjectState> mapEventToState(ProjectEvent event) async* {
    if (event is LoadProject) {
      try {
        final userToken = await _getUserTokenForProject(event.project);

        yield ProjectLoaded(userToken: userToken);
      }
      catch (_) {
        yield ProjectError();
      }
    }
  }

  Future<String> _getUserTokenForProject(Project project) async {
    const userId = 'default-user';
    const skypeId = 'User';
    final url = '${settings.backendUrl}/StartSkypeSession/$skypeId/$userId/${Uri.encodeFull(project.name)}';
    final response = await restClient.get(url);

    return json.decode(response.body);
  }
}
