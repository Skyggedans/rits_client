import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/utils.dart';
import 'projects.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsRepository projectsRepository;

  ProjectsBloc({@required this.projectsRepository})
      : assert(projectsRepository != null);

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
          final projects = await projectsRepository.fetchProjects();

          yield ProjectsLoaded(projects: projects);
        }
      } on ApiError {
        yield ProjectsError();
      }
    }
  }
}
