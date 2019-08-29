import 'package:flutter/material.dart';

import '../associated_data_item/associated_data_item.dart';
import '../chart/chart.dart';
import '../kpi/kpi.dart';
import '../report/report.dart';
import '../tabular_data/tabular_data.dart';

class ProjectRoutes {
  static final routes = <String, WidgetBuilder>{
    ReportScreen.route: (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return ReportScreen(
        viewObject: args['viewObject'],
      );
    },
    ChartScreen.route: (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return ChartScreen(
        viewObject: args['viewObject'],
      );
    },
    TabularDataScreen.route: (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return TabularDataScreen(
        viewObject: args['viewObject'],
      );
    },
    KpiScreen.route: (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return KpiScreen(
        viewObject: args['viewObject'],
      );
    },
    AssociatedDataItemScreen.route: (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return AssociatedDataItemScreen(
        viewObject: args['viewObject'],
      );
    },
  };
}
