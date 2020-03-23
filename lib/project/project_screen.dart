import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/associated_data_item/associated_data_item.dart';
import 'package:rits_client/associated_data_items/associated_data_items.dart';
import 'package:rits_client/chart/chart.dart';
import 'package:rits_client/comments/comments_screen.dart';
import 'package:rits_client/filter_groups/filter_groups_screen.dart';
import 'package:rits_client/kpi/kpi.dart';
import 'package:rits_client/luis/luis.dart';
import 'package:rits_client/matching_items_search/matching_items_search.dart';
import 'package:rits_client/models/filter_groups/filter.dart';
import 'package:rits_client/my_favorites/my_favorites_screen.dart';
import 'package:rits_client/report/report.dart';
import 'package:rits_client/tabular_data/tabular_data.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_objects/view_objects.dart';

import 'project.dart';

class ProjectScreen extends StatefulWidget {
  ProjectScreen({Key key}) : super(key: key);

  @override
  State createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  ProjectBloc _bloc;
  bool _isRealWearDevice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      final appContext = Provider.of<AppContext>(context);

      _isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;

      _bloc = ProjectBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: appContext,
      )..add(LoadProject(appContext.project));
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RestClient, AppContext>(
      builder: (context, restClient, appContext, __) => BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, ProjectState state) {
          String title = appContext.project.name;
          Widget bodyChild;
          List<Widget> actions;

          if (state is ProjectLoading) {
            bodyChild = CircularProgressIndicator();
          } else if (state is ProjectLoaded) {
            title = appContext.sessionContextName != null
                ? '${appContext.project.name} > ${appContext.sessionContextName}'
                : appContext.project.name;

            bodyChild = Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Observed item selector',
                            textAlign: TextAlign.left,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Visibility(
                                visible: _isRealWearDevice,
                                child: FlatButton(
                                  child: Column(
                                    children: <Widget>[
                                      const Icon(
                                        FontAwesomeIcons.qrcode,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                      Container(
                                        height: 10,
                                      ),
                                      const Text('Scan Bar Code'),
                                    ],
                                  ),
                                  onPressed: () {
                                    _bloc.add(ScanBarcode());
                                  },
                                ),
                              ),
                              FlatButton(
                                child: Column(
                                  children: <Widget>[
                                    const Icon(
                                      FontAwesomeIcons.filter,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                    Container(
                                      height: 10,
                                    ),
                                    const Text('Filter Groups'),
                                  ],
                                ),
                                onPressed: () async {
                                  final selectedFilter = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FilterGroupsScreen(),
                                    ),
                                  ) as Filter;

                                  if (selectedFilter != null) {
                                    _bloc.add(SetContextFromFilter(
                                      filter: selectedFilter,
                                    ));
                                  }
                                },
                              ),
                              FlatButton(
                                child: Column(
                                  children: <Widget>[
                                    const Icon(
                                      FontAwesomeIcons.search,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                    Container(
                                      height: 10,
                                    ),
                                    const Text('Search Item'),
                                  ],
                                ),
                                onPressed: () async {
                                  final selectedContext = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MatchingItemsSearchScreen(),
                                    ),
                                  ) as String;

                                  if (selectedContext != null) {
                                    _bloc.add(SetContextFromSearch(
                                      sessionContext: selectedContext,
                                    ));
                                  }
                                },
                              ),
                            ],
                          ),
                        ]),
                  ),
                ),
                Visibility(
                  visible: appContext.sessionContextName != null,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                          'Observed item: ${appContext.sessionContextName}'),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceAround,
                            spacing: 5,
                            children: <Widget>[
                              Visibility(
                                visible: _isRealWearDevice &&
                                    appContext.sessionContextName != null,
                                maintainSize: false,
                                child: RaisedButton(
                                  child: const Text('Take Photo'),
                                  onPressed: () async {
                                    _bloc.add(TakePhoto());
                                  },
                                ),
                              ),
                              Visibility(
                                visible: _isRealWearDevice &&
                                    appContext.sessionContextName != null,
                                maintainSize: false,
                                child: RaisedButton(
                                  child: const Text('Record Video'),
                                  onPressed: () async {
                                    _bloc.add(RecordVideo());
                                  },
                                ),
                              ),
                              RaisedButton(
                                child: const Text('Start LUIS'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LuisScreen(),
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
                                        type: 'Reports',
                                        detailsScreenRoute: ReportScreen.route,
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
                                        type: 'Charts',
                                        detailsScreenRoute: ChartScreen.route,
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
                                        title: 'Tabular Data',
                                        type: 'DataObjects',
                                        detailsScreenRoute:
                                            TabularDataScreen.route,
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
                                        type: 'KPIs',
                                        detailsScreenRoute: KpiScreen.route,
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
                                        builder: (context) =>
                                            Provider<ViewObjectsRepository>(
                                          create: (_) =>
                                              AssociatedDataItemsRepository(
                                            restClient: restClient,
                                            appContext: appContext,
                                          ),
                                          child: ViewObjectsScreen(
                                            title: 'Associated Data',
                                            detailsScreenRoute:
                                                AssociatedDataItemScreen.route,
                                          ),
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
                                        builder: (context) => CommentsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              RaisedButton(
                                child: Text('Show My Favorites'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyFavoritesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
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
      ),
    );
  }
}
