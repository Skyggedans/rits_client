import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../project/project.dart';
import 'projects.dart';

class ProjectsScreen extends StatefulWidget {
  ProjectsScreen({Key key}) : super(key: key);

  @override
  State createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectsBloc _projectsBloc = ProjectsBloc(restClient: RestClient());

  @override
  void initState() {
    super.initState();
    _projectsBloc.dispatch(FetchProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: Center(
          child: BlocBuilder(
            bloc: _projectsBloc,
            builder: (BuildContext context, ProjectsState state) {
              if (state is ProjectsUninitialized) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              else if (state is ProjectsLoaded) {
                return BlocProvider(
                  bloc: _projectsBloc,
                  child: _ProjectButtons(),
                );
              }
              else if (state is ProjectsError) {
                return Center(
                  child: Text('Failed to fetch projects'),
                );
              }
            },
          )),
    );
  }

  @override
  void dispose() {
    _projectsBloc.dispose();
    super.dispose();
  }
}

class _ProjectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _projectsBloc = BlocProvider.of<ProjectsBloc>(context);

    return BlocBuilder(
      bloc: _projectsBloc,
      builder: (BuildContext context, ProjectsState state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (state as ProjectsLoaded).projects.map((project) {
            return RaisedButton(
                child: Text(project.name),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectScreen(project: project),
                    ),
                  );
                });
          }).toList(),
        );
      },
    );
  }
}
