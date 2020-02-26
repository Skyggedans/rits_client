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
                ? '${appContext.project.name} - ${appContext.sessionContextName}'
                : appContext.project.name;

            actions = <Widget>[
              Visibility(
                visible: _isRealWearDevice,
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
                  onPressed: () {
                    _bloc.add(ScanBarcode());
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
                          builder: (context) =>
                              MatchingItemsSearchScreen(searchString: value),
                        ),
                      ) as String;

                      if (selectedContext != null) {
                        _bloc.add(SetContextFromSearch(
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
                              detailsScreenRoute: TabularDataScreen.route,
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
                                create: (_) => AssociatedDataItemsRepository(
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
                      child: Text('Show Filter Groups'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilterGroupsScreen(),
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
                            builder: (context) => MyFavoritesScreen(),
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
      ),
    );
  }
}
