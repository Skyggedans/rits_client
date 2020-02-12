import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/utils/rest_client.dart';

import '../project/project.dart';
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

    Provider.of<ProjectsBloc>(context).add(FetchProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsBloc>(
      builder: (context, bloc, _) => Scaffold(
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

            return const Center(
              child: Text('Failed to fetch projects'),
            );
          },
        )),
      ),
    );
  }
}

class _ProjectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppContext, ProjectsBloc>(
      builder: (context, appContext, projectsBloc, _) => BlocBuilder(
        bloc: projectsBloc,
        builder: (BuildContext context, ProjectsState state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (state as ProjectsLoaded).projects.map((project) {
              return RaisedButton(
                  child: Text(project.name),
                  onPressed: () async {
                    appContext.project = project;

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProxyProvider<RestClient, ProjectBloc>(
                          update: (_, restClient, __) => ProjectBloc(
                            restClient: restClient,
                            appContext: appContext,
                          ), //..add(LoadProject(project)),
                          dispose: (_, bloc) => bloc.close(),
                          child: ProjectScreen(),
                        ),
                      ),
                    );
                  });
            }).toList(),
          );
        },
      ),
    );
  }
}
