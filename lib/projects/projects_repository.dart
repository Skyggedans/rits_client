import 'package:flutter/material.dart';

import 'package:rits_client/models/projects/project.dart';
import 'projects.dart';

class ProjectsRepository {
  final ProjectsDao projectsDao;

  ProjectsRepository({@required this.projectsDao})
      : assert(projectsDao != null);

  Future fetchProjects() => projectsDao.getProjects();
}
