import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/projects/projects.dart';
import 'projects.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final RestClient restClient;

  ProjectsBloc({@required this.restClient});

  @override
  Stream<ProjectsEvent> transform(Stream<ProjectsEvent> events) {
    return (events as Observable<ProjectsEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => ProjectsUninitialized();

  @override
  Stream<ProjectsState> mapEventToState(ProjectsEvent event) async* {
    if (event is FetchProjects) {
      try {
        if (currentState is ProjectsUninitialized) {
          final projects = await _fetchProjects();

          yield ProjectsLoaded(projects: projects);

          return;
        }
      }
      catch (_) {
        yield ProjectsError();
      }
    }
  }

  Future<List<Project>> _fetchProjects() async {
    const url = '${settings.backendUrl}/GetProjects';
    dynamic response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((param) {
      return Project.fromJson(param);
    }).toList();
  }
}
