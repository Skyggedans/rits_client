import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/project/project.dart';
import 'package:rits_client/utils/rest_client.dart';

import 'projects.dart';

class ProjectsScreen extends StatefulWidget {
  ProjectsScreen({Key key}) : super(key: key);

  @override
  State createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ProjectsBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = ProjectsBloc(restClient: Provider.of<RestClient>(context))
        ..add(FetchProjects());
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: Center(
        child: BlocBuilder(
          cubit: _bloc,
          builder: (BuildContext context, ProjectsState state) {
            if (state is ProjectsUninitialized) {
              return CircularProgressIndicator();
            } else if (state is ProjectsLoaded) {
              return Provider.value(
                value: _bloc,
                child: _ProjectButtons(),
              );
            }

            return const Center(
              child: Text('Failed to fetch projects'),
            );
          },
        ),
      ),
      //),
    );
  }
}

class _ProjectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppContext, ProjectsBloc>(
      builder: (context, appContext, projectsBloc, _) => BlocBuilder(
        cubit: projectsBloc,
        builder: (BuildContext context, ProjectsState state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (state as ProjectsLoaded).projects.map((project) {
              return RaisedButton(
                  child: Text(project.name),
                  onPressed: () async {
                    appContext.project = project;
                    appContext.sessionContext = null;

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectScreen(),
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
