import 'package:flutter/material.dart';

import 'chart/chart.dart';
import 'report/report.dart';
import 'tabular_data/tabular_data.dart';
import 'kpi/kpi.dart';

final routes = <String, WidgetBuilder>{
  ReportScreen.route: (BuildContext context) {
    final dynamic args = ModalRoute.of(context).settings.arguments;

    return ReportScreen(
      viewObject: args['viewObject'],
      userToken: args['userToken'],
    );
  },
  ChartScreen.route: (BuildContext context) {
    final dynamic args = ModalRoute.of(context).settings.arguments;

    return ChartScreen(
      viewObject: args['viewObject'],
      userToken: args['userToken'],
    );
  },
  TabularDataScreen.route: (BuildContext context) {
    final dynamic args = ModalRoute.of(context).settings.arguments;

    return TabularDataScreen(
      viewObject: args['viewObject'],
      userToken: args['userToken'],
    );
  },
  KpiScreen.route: (BuildContext context) {
    final dynamic args = ModalRoute.of(context).settings.arguments;

    return KpiScreen(
      viewObject: args['viewObject'],
      userToken: args['userToken'],
    );
  },
};
