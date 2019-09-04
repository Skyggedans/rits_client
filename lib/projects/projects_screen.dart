import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/project/project.dart';

import 'projects.dart';

class ProjectsScreen extends StatefulWidget {
  ProjectsScreen({Key key}) : super(key: key);

  @override
  State createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final projectsBloc = Provider.of<ProjectsBloc>(context);

    if (projectsBloc.currentState == projectsBloc.initialState) {
      projectsBloc.dispatch(FetchProjects());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsBloc>(
      builder: (context, bloc, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Projects'),
          ),
          body: Center(
              child: BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, ProjectsState state) {
              if (state is ProjectsUninitialized) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ProjectsLoaded) {
                return _ProjectButtons();
              }

              return Center(
                child: Text('Failed to fetch projects'),
              );
            },
          )),
        );
      },
    );
  }
}

class _ProjectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsBloc>(
      builder: (context, bloc, child) {
        return BlocBuilder(
          bloc: bloc,
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
                          builder: (context) => Provider<ProjectBloc>.value(
                            value: ProjectBloc(),
                            child: ProjectScreen(project: project),
                          ),
                        ),
                      );
                    });
              }).toList(),
            );
          },
        );
      },
    );
  }
}
