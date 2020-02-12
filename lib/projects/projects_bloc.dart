import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../models/projects/projects.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'projects.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final RestClient restClient;

  ProjectsBloc({@required this.restClient})
      : assert(restClient != null),
        super();

  @override
  Stream<ProjectsState> transformStates(Stream<ProjectsState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  get initialState => ProjectsUninitialized();

  @override
  Stream<ProjectsState> mapEventToState(ProjectsEvent event) async* {
    if (event is FetchProjects) {
      try {
        if (state is ProjectsUninitialized) {
          final projects = await _fetchProjects();

          yield ProjectsLoaded(projects: projects);
        }
      } on ApiError {
        yield ProjectsError();
      }
    }
  }

  Future<List<Project>> _fetchProjects() async {
    const url = '${settings.backendUrl}/GetProjects';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((paramJson) {
      return Project.fromJson(paramJson);
    }).toList();
  }
}
