import 'package:equatable/equatable.dart';
import 'package:rits_client/models/projects/projects.dart';

abstract class ProjectsEvent extends Equatable {
  ProjectsEvent([List props = const []]) : super(props);
}

class SelectProject extends ProjectsEvent {
  final Project project;

  SelectProject(this.project) : super([project]);

  @override
  String toString() => 'SelectProject { project: ${project.name} }';
}

class FetchProjects extends ProjectsEvent {
  @override
  String toString() => 'FetchProjects';
}
