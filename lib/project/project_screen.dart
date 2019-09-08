import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/associated_data_item/associated_data_item.dart';
import 'package:rits_client/associated_data_items/associated_data_items.dart';
import 'package:rits_client/chart/chart.dart';
import 'package:rits_client/comments/comments_screen.dart';
import 'package:rits_client/kpi/kpi.dart';
import 'package:rits_client/locator.dart';
import 'package:rits_client/luis/luis.dart';
import 'package:rits_client/matching_items_search/matching_items_search.dart';
import 'package:rits_client/models/app_config.dart';
import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/report/report.dart';
import 'package:rits_client/tabular_data/tabular_data.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_objects/view_objects.dart';

import 'project.dart';

class ProjectScreen extends StatefulWidget {
  @override
  State createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Project get _project => Provider.of<Project>(context);
  ProjectBloc get _projectBloc => Provider.of<ProjectBloc>(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_projectBloc.currentState == _projectBloc.initialState) {
      _projectBloc.dispatch(LoadProject(_project));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _projectBloc,
      builder: (BuildContext context, ProjectState state) {
        Widget bodyChild;

        if (state is ProjectLoading) {
          bodyChild = CircularProgressIndicator();
        } else if (state is ProjectLoaded) {
          return Provider<ProjectContext>.value(
            value: ProjectContext(
              project: _project,
              userToken: state.userToken,
              hierarchyLevel: state.hierarchyLevel,
            ),
            child: Navigator(
              onGenerateRoute: _getRoutes,
            ),
          );
        } else if (state is ProjectError) {
          bodyChild = Text(state.message ?? '');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_project.name),
          ),
          body: Center(child: bodyChild),
        );
      },
    );
  }

  Route<BuildContext> _getRoutes(RouteSettings settings) {
    final builder = ProjectRoutes.routes[settings.name];

    if (builder != null) {
      return new MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    } else {
      final parentContext = context;

      return MaterialPageRoute(
        builder: (context) {
          Future.delayed(Duration.zero, () {
            ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(
              onRemove: () {
                Navigator.pop(parentContext);
              },
            ));
          });

          return _buildPage(context);
        },
      );
    }
  }

  Widget _buildPage(BuildContext context) {
    final state = _projectBloc.currentState as ProjectLoaded;
    final title = state.context != null
        ? '${_project.name} - ${state.context}'
        : _project.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _buildActions(context, state),
      ),
      body: Center(child: _buildButtons(context, state)),
    );
  }

  List<Widget> _buildActions(BuildContext context, ProjectLoaded state) {
    final isRealWearDevice = locator<AppConfig>().isRealWearDevice;

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
    final isRealWearDevice = locator<AppConfig>().isRealWearDevice;

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
                    builder: (context) => LuisScreen(),
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
                    builder: (context) => ViewObjectsScreen(
                      type: 'Charts',
                      detailsScreenRoute: ChartScreen.route,
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
              child: Text('Show KPIs'),
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
              visible: state.hierarchyLevel != null,
              child: RaisedButton(
                child: Text('Show Associated Data'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewObjectsScreen(
                        title: 'Associated Data',
                        detailsScreenRoute: AssociatedDataItemScreen.route,
                        viewObjectsRepository: AssociatedDataItemsRepository(
                            restClient: RitsClient()),
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
                      builder: (context) => CommentsScreen(),
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
}
