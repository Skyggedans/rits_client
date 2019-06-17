import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rw_camera/rw_camera.dart';

import '../chart/chart.dart';
import '../kpi/kpi.dart';
import '../luis/luis.dart';
import '../models/projects/projects.dart';
import '../report/report.dart';
import '../tabular_data/tabular_data.dart';
import '../utils/rest_client.dart';
import '../view_objects/view_objects.dart';
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
          if (state is ProjectLoading) {
            return CircularProgressIndicator();
          } else if (state is ProjectLoaded) {
            return new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: state.hierarchyLevel != null,
                    child: Text(
                      'Bound to: ${state.context}',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: const Text('Scan Bar Code'),
                    color: Colors.blue,
                    onPressed: () {
                      _projectBloc
                          .dispatch(ScanBarcode(userToken: state.userToken));
                    },
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    spacing: 10,
                    children: <Widget>[
                      Visibility(
                        visible: state.hierarchyLevel != null,
                        maintainSize: false,
                        child: RaisedButton(
                          child: const Text('Take Photo'),
                          onPressed: () async {
                            _projectBloc.dispatch(PhotoTaken(
                                await RwCamera.takePhoto(), state.userToken));
                          },
                        ),
                      ),
                      Visibility(
                        visible: state.hierarchyLevel != null,
                        maintainSize: false,
                        child: RaisedButton(
                          child: const Text('Record Video'),
                          onPressed: () async {
                            _projectBloc.dispatch(VideoRecorded(
                                await RwCamera.recordVideo(), state.userToken));
                          },
                        ),
                      ),
                      RaisedButton(
                        child: const Text('Start LUIS'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LuisScreen(
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
                                    type: 'Reports',
                                    detailsScreenRoute: ReportScreen.route,
                                    hierarchyLevel: state.hierarchyLevel,
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
                                    type: 'Charts',
                                    detailsScreenRoute: ChartScreen.route,
                                    hierarchyLevel: state.hierarchyLevel,
                                    userToken: state.userToken,
                                  ),
                            ),
                          );
                        },
                      ),
                      RaisedButton(
                        child: Text('Tabular Data'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewObjectsScreen(
                                    project: _project,
                                    type: 'DataObjects',
                                    detailsScreenRoute: TabularDataScreen.route,
                                    hierarchyLevel: state.hierarchyLevel,
                                    userToken: state.userToken,
                                  ),
                            ),
                          );
                        },
                      ),
                      RaisedButton(
                        child: Text('KPIs'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewObjectsScreen(
                                    project: _project,
                                    type: 'KPIs',
                                    detailsScreenRoute: KpiScreen.route,
                                    hierarchyLevel: state.hierarchyLevel,
                                    userToken: state.userToken,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ]);
          } else if (state is ProjectError) {
            return Text(state.message);
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
