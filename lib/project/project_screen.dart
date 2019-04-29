import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../models/projects/projects.dart';
import '../view_objects/view_objects.dart';
import '../chart/chart.dart';
import '../report/report.dart';
import '../poi/poi.dart';
import 'project.dart';

class ProjectScreen extends StatefulWidget {
  final Project project;

  ProjectScreen({Key key, @required this.project}) : super(key: key);

  @override
  State createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final ProjectBloc _projectBloc = ProjectBloc(restClient: RestClient());

  Project get _project => widget.project;

  @override
  void initState() {
    super.initState();
    _projectBloc.dispatch(LoadProject(_project));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: _projectBloc,
        builder: (BuildContext context, ProjectState state) {
          if (state is ProjectUninitialized) {
            return CircularProgressIndicator();
          } else if (state is ProjectLoaded) {
            return new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    child: const Text('Scan Bar Code'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoiScreen(
                                project: _project,
                                userToken: state.userToken,
                              ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Reports'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewObjectsScreen(
                                project: _project,
                                type: 'Report',
                                detailsScreenRoute: ReportScreen.route,
                                userToken: state.userToken,
                              ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Charts'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewObjectsScreen(
                                project: _project,
                                type: 'Chart',
                                detailsScreenRoute: ChartScreen.route,
                                userToken: state.userToken,
                              ),
                        ),
                      );
                    },
                  ),
                ]);
          } else if (state is ProjectError) {
            return const Text('Failed to load project');
          }
        },
      )),
    );
  }

  @override
  void dispose() {
    _projectBloc.dispose();
    super.dispose();
  }
}
