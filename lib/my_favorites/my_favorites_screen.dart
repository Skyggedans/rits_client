import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../chart/chart.dart';
import '../kpi/kpi.dart';
import '../models/projects/projects.dart';
import '../report/report.dart';
import '../tabular_data/tabular_data.dart';
import '../view_objects/view_objects.dart';

class MyFavoritesScreen extends StatefulWidget {
  final Project project;
  final String userToken;
  final String hierarchyLevel;

  MyFavoritesScreen({
    Key key,
    @required this.project,
    @required this.userToken,
    this.hierarchyLevel,
  })  : assert(project != null),
        assert(userToken != null),
        super(key: key);

  @override
  State createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  Project get _project => widget.project;
  String get _userToken => widget.userToken;
  String get _hierarchyLevel => widget.hierarchyLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      hierarchyLevel: _hierarchyLevel,
                      userToken: _userToken,
                      favorite: true,
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
                      hierarchyLevel: _hierarchyLevel,
                      userToken: _userToken,
                      favorite: true,
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
                      hierarchyLevel: _hierarchyLevel,
                      userToken: _userToken,
                      favorite: true,
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
                      hierarchyLevel: _hierarchyLevel,
                      userToken: _userToken,
                      favorite: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
