import 'package:flutter/material.dart';

import '../models/projects/project.dart';
import 'projects.dart';

class ProjectsRepository {
  final ProjectsDao projectsDao;

  ProjectsRepository({@required this.projectsDao})
      : assert(projectsDao != null);

  Future fetchProjects() => projectsDao.getProjects();
}
