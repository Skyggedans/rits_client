import 'package:equatable/equatable.dart';

import 'package:rits_client/models/projects/projects.dart';

abstract class ProjectsState extends Equatable {
  ProjectsState([List props = const []]) : super(props);
}

class ProjectsUninitialized extends ProjectsState {
  @override
  String toString() => 'ProjectsUninitialized';
}

class ProjectsError extends ProjectsState {
  @override
  String toString() => 'ProjectsError';
}

class ProjectsLoaded extends ProjectsState {
  final List<Project> projects;

  ProjectsLoaded({
    this.projects,
  }) : super([projects]);

  ProjectsLoaded copyWith({
    List<Project> projects,
  }) {
    return ProjectsLoaded(
      projects: projects ?? this.projects,
    );
  }

  @override
  String toString() => 'ProjectsLoaded { parameters: ${projects.length} }';
}

class ProjectSelected extends ProjectsState {
  final Project project;
  final String userToken;

  ProjectSelected({this.project, this.userToken}) : super([project, userToken]);
}