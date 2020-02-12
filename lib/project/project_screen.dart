import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
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
import '../report/report.dart';
import '../tabular_data/tabular_data.dart';
import '../utils/rest_client.dart';
import '../view_objects/view_objects.dart';
import 'project.dart';

class ProjectScreen extends StatefulWidget {
  ProjectScreen({Key key}) : super(key: key);

  @override
  State createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool isRealWearDevice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;

    final appContext = Provider.of<AppContext>(context, listen: false);

    Provider.of<ProjectBloc>(context).add(LoadProject(appContext.project));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ProjectBloc>(context);

    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, ProjectState state) {
        final appContext = Provider.of<AppContext>(context, listen: false);
        String title = appContext.project.name;
        Widget bodyChild;
        List<Widget> actions;

        if (state is ProjectLoading) {
          bodyChild = CircularProgressIndicator();
        } else if (state is ProjectLoaded) {
          title = appContext.sessionContextName != null
              ? '${appContext.project.name} - ${appContext.sessionContextName}'
              : appContext.project.name;

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
                  bloc.add(ScanBarcode());
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
                          userToken: appContext.userToken,
                        ),
                      ),
                    ) as String;

                    if (selectedContext != null) {
                      bloc.add(SetContextFromSearch(
                        sessionContext: selectedContext,
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
                    visible: isRealWearDevice &&
                        appContext.sessionContextName != null,
                    maintainSize: false,
                    child: RaisedButton(
                      child: const Text('Take Photo'),
                      onPressed: () async {
                        bloc.add(TakePhoto());
                      },
                    ),
                  ),
                  Visibility(
                    visible: isRealWearDevice &&
                        appContext.sessionContextName != null,
                    maintainSize: false,
                    child: RaisedButton(
                      child: const Text('Record Video'),
                      onPressed: () async {
                        bloc.add(RecordVideo());
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
                            project: appContext.project,
                            userToken: appContext.userToken,
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
                            project: appContext.project,
                            type: 'Reports',
                            detailsScreenRoute: ReportScreen.route,
                            hierarchyLevel: appContext.sessionContextName,
                            userToken: appContext.userToken,
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
                            project: appContext.project,
                            type: 'Charts',
                            detailsScreenRoute: ChartScreen.route,
                            hierarchyLevel: appContext.sessionContextName,
                            userToken: appContext.userToken,
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
                            project: appContext.project,
                            title: 'Tabular Data',
                            type: 'DataObjects',
                            detailsScreenRoute: TabularDataScreen.route,
                            hierarchyLevel: appContext.sessionContextName,
                            userToken: appContext.userToken,
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
                            project: appContext.project,
                            type: 'KPIs',
                            detailsScreenRoute: KpiScreen.route,
                            hierarchyLevel: appContext.sessionContextName,
                            userToken: appContext.userToken,
                          ),
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: appContext.sessionContextName != null,
                    child: RaisedButton(
                      child: const Text('Show Associated Data'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewObjectsScreen(
                              project: appContext.project,
                              title: 'Associated Data',
                              detailsScreenRoute:
                                  AssociatedDataItemScreen.route,
                              viewObjectsRepository:
                                  AssociatedDataItemsRepository(
                                      restClient: RestClient()),
                              userToken: appContext.userToken,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: appContext.sessionContextName != null,
                    child: RaisedButton(
                      child: const Text('Show Comments'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              userToken: appContext.userToken,
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
                            userToken: appContext.userToken,
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
                            userToken: appContext.userToken,
                            project: appContext.project,
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
