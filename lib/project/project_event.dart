import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/projects/projects.dart';

@immutable
abstract class ProjectEvent extends Equatable {
  ProjectEvent([List props = const []]) : super(props);
}

class LoadProject extends ProjectEvent {
  final Project project;

  LoadProject(this.project) : super([project]);

  @override
  String toString() => 'LoadProject { project: ${project.name} }';
}
