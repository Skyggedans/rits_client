import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'project.dart';

class ProjectContext extends Equatable {
  final Project project;
  final String userToken;
  final String hierarchyLevel;

  ProjectContext({
    @required this.project,
    @required this.userToken,
    this.hierarchyLevel,
  }) : super([
          project,
          userToken,
          hierarchyLevel,
        ]);
}
