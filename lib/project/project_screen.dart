import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rits_client/filter_groups/filter_groups_screen.dart';
import 'package:rits_client/my_favorites/my_favorites_screen.dart';

import '../app_config.dart';
import '../associated_data_item/associated_data_item.dart';
import '../associated_data_items/associated_data_items.dart';
import '../chart/chart.dart';
import '../comments/comments_screen.dart';
import '../kpi/kpi.dart';
import '../luis/luis.dart';
import '../matching_items_search/matching_items_search.dart';
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
  bool isRealWearDevice;

  Project get _project => widget.project;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isRealWearDevice = AppConfig.of(context).isRealWearDevice;
  }

  @override
  void initState() {
    super.initState();
    _projectBloc.add(LoadProject(_project));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _projectBloc,
      builder: (BuildContext context, ProjectState state) {
        String title = _project.name;
        Widget bodyChild;
        List<Widget> actions;

        if (state is ProjectLoading) {
          bodyChild = CircularProgressIndicator();
        } else if (state is ProjectLoaded) {
          title = state.context != null
              ? '${_project.name} - ${state.context}'
              : _project.name;

          actions = <Widget>[
            Visibility(
              visible: isRealWearDevice,
              child: FlatButton(
                child: Row(
                  children: <Widget>[
                    const Icon(
                      FontAwesomeIcons.qrcode,
                      color: Colors.white,
                      size: 24,
                    ),
                    Container(
                      width: 10,
                    ),
                    const Text('Scan Bar Code'),
                  ],
                ),
                //color: Colors.blue,
                onPressed: () {
                  _projectBloc.add(ScanBarcode(userToken: state.userToken));
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: Semantics(
                //textField: true,
                value: 'Search Item',
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    labelText: 'Search Item',
                    alignLabelWithHint: true,
                  ),
                  onFieldSubmitted: (value) async {
                    final selectedContext = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingItemsSearchScreen(
                          searchString: value,
                          userToken: state.userToken,
                        ),
                      ),
                    ) as String;

                    if (selectedContext != null) {
                      _projectBloc.add(SetContextFromSearch(
                        context: selectedContext,
                        userToken: state.userToken,
                      ));
                    }
                  },
                ),
              ),
            ),
          ];

          bodyChild = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 10,
                children: <Widget>[
                  Visibility(
                    visible: isRealWearDevice && state.hierarchyLevel != null,
                    maintainSize: false,
                    child: RaisedButton(
                      child: const Text('Take Photo'),
                      onPressed: () async {
                        _projectBloc.add(TakePhoto(userToken: state.userToken));
                      },
                    ),
                  ),
                  Visibility(
                    visible: isRealWearDevice && state.hierarchyLevel != null,
                    maintainSize: false,
                    child: RaisedButton(
                      child: const Text('Record Video'),
                      onPressed: () async {
                        _projectBloc
                            .add(RecordVideo(userToken: state.userToken));
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
                    child: const Text('Show Reports'),
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
                    child: const Text('Show Charts'),
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
                    child: const Text('Show Tabular Data'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewObjectsScreen(
                            project: _project,
                            title: 'Tabular Data',
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
                    child: const Text('Show KPIs'),
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
                  Visibility(
                    visible: state.hierarchyLevel != null,
                    child: RaisedButton(
                      child: const Text('Show Associated Data'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewObjectsScreen(
                              project: _project,
                              title: 'Associated Data',
                              detailsScreenRoute:
                                  AssociatedDataItemScreen.route,
                              viewObjectsRepository:
                                  AssociatedDataItemsRepository(
                                      restClient: RestClient()),
                              userToken: state.userToken,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: state.hierarchyLevel != null,
                    child: RaisedButton(
                      child: const Text('Show Comments'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              userToken: state.userToken,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  RaisedButton(
                    child: Text('Show Filter Groups'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterGroupsScreen(
                            userToken: state.userToken,
                          ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Show My Favorites'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyFavoritesScreen(
                            userToken: state.userToken,
                            project: _project,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        } else if (state is ProjectError) {
          bodyChild = Text(state.message ?? '');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: actions,
          ),
          body: Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(child: bodyChild),
          ),
        );
      },
    );
  }
}
