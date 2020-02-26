import 'package:flutter/material.dart';
import 'package:rits_client/chart/chart.dart';
import 'package:rits_client/kpi/kpi.dart';
import 'package:rits_client/report/report.dart';
import 'package:rits_client/tabular_data/tabular_data.dart';
import 'package:rits_client/view_objects/view_objects.dart';

class MyFavoritesScreen extends StatefulWidget {
  @override
  State createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
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
                      type: 'Reports',
                      detailsScreenRoute: ReportScreen.route,
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
                      type: 'Charts',
                      detailsScreenRoute: ChartScreen.route,
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
                      title: 'Tabular Data',
                      type: 'DataObjects',
                      detailsScreenRoute: TabularDataScreen.route,
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
                      type: 'KPIs',
                      detailsScreenRoute: KpiScreen.route,
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
