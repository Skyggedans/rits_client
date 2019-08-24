import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/authentication/authentication_provider.dart';
import 'package:rits_client/authentication/authentication_repository.dart';
import 'package:rits_client/routes.dart';

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

  Project get _project => widget.project;

  @override
  void initState() {
    super.initState();
    _projectBloc.dispatch(LoadProject(_project));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _projectBloc,
      builder: (BuildContext context, ProjectState state) {
        final isRealWearDevice = AppConfig.of(context).isRealWearDevice;
        String title = _project.name;
        Widget bodyChild;
        List<Widget> actions;

        if (state is ProjectLoading) {
          bodyChild = CircularProgressIndicator();
        } else if (state is ProjectLoaded) {
          title = state.context != null
              ? '${_project.name} - ${state.context}'
              : _project.name;

          Route<BuildContext> _getRoutes(RouteSettings settings) {
            var builder = Routes.get(
                authRepository: AuthRepository(
                    authProvider: AuthProvider()))[settings.name];

            if (builder != null) {
              return new MaterialPageRoute(
                settings: settings,
                builder: builder,
              );
            } else {
              return MaterialPageRoute(
                builder: (context) {
                  return _buildButtons(context, state);
                },
              );
            }

            return null;
          }

          bodyChild = Navigator(
            onGenerateRoute: _getRoutes,
          );

          return _injectProjectContext(
            Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: _buildActions(context, state),
              ),
              body: Center(child: bodyChild),
            ),
            state.userToken,
            state.hierarchyLevel,
          );
        } else if (state is ProjectError) {
          bodyChild = Text(state.message ?? '');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Center(child: bodyChild),
        );
      },
    );
  }

  @override
  void dispose() {
    _projectBloc.dispose();
    super.dispose();
  }

  List<Widget> _buildActions(BuildContext context, ProjectLoaded state) {
    final isRealWearDevice = AppConfig.of(context).isRealWearDevice;

    return <Widget>[
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
            _projectBloc.dispatch(ScanBarcode(userToken: state.userToken));
          },
        ),
      ),
      SizedBox(
        width: 200,
        child: TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.search),
            labelText: 'Search Item',
            helperText: 'Search Item',
            alignLabelWithHint: true,
            helperStyle: TextStyle(
              fontSize: 1,
              color: Color.fromARGB(0, 0, 0, 0),
            ),
          ),
          onFieldSubmitted: (value) async {
            final selectedContext = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MatchingItemsSearchScreen(searchString: value),
              ),
            );

            if (selectedContext != null) {
              _projectBloc.dispatch(SetContextFromSearch(
                context: selectedContext,
                userToken: state.userToken,
              ));
            }
          },
        ),
      ),
    ];
  }

  Widget _buildButtons(BuildContext context, ProjectLoaded state) {
    final isRealWearDevice = AppConfig.of(context).isRealWearDevice;

    return Column(
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
                  _projectBloc.dispatch(TakePhoto(userToken: state.userToken));
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
                      .dispatch(RecordVideo(userToken: state.userToken));
                },
              ),
            ),
            RaisedButton(
              child: const Text('Start LUIS'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _injectProjectContext(
                      LuisScreen(),
                      state.userToken,
                      state.hierarchyLevel,
                    ),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text('Show Reports'),
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
              child: Text('Show Charts'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _injectProjectContext(
                      ViewObjectsScreen(
                        type: 'Charts',
                        detailsScreenRoute: ChartScreen.route,
                      ),
                      state.userToken,
                      state.hierarchyLevel,
                    ),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text('Show Tabular Data'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _injectProjectContext(
                      ViewObjectsScreen(
                        title: 'Tabular Data',
                        type: 'DataObjects',
                        detailsScreenRoute: TabularDataScreen.route,
                      ),
                      state.userToken,
                      state.hierarchyLevel,
                    ),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text('Show KPIs'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _injectProjectContext(
                      ViewObjectsScreen(
                        type: 'KPIs',
                        detailsScreenRoute: KpiScreen.route,
                      ),
                      state.userToken,
                      state.hierarchyLevel,
                    ),
                  ),
                );
              },
            ),
            Visibility(
              visible: state.hierarchyLevel != null,
              child: RaisedButton(
                child: Text('Show Associated Data'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _injectProjectContext(
                        ViewObjectsScreen(
                          title: 'Associated Data',
                          detailsScreenRoute: AssociatedDataItemScreen.route,
                          viewObjectsRepository: AssociatedDataItemsRepository(
                              restClient: RestClient()),
                        ),
                        state.userToken,
                        state.hierarchyLevel,
                      ),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: state.hierarchyLevel != null,
              child: RaisedButton(
                child: Text('Show Comments'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _injectProjectContext(
                        CommentsScreen(),
                        state.userToken,
                        state.hierarchyLevel,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _injectProjectContext(Widget screen, String userToken,
      [String hierarchyLevel]) {
    return Provider<ProjectContext>.value(
      value: ProjectContext(
        project: _project,
        userToken: userToken,
        hierarchyLevel: hierarchyLevel,
      ),
      child: screen,
    );
  }
}

class ProjectWrapper extends InheritedWidget {
  final ProjectContext projectContext;

  ProjectWrapper({Widget child, this.projectContext}) : super(child: child);

  static ProjectWrapper of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ProjectWrapper);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
