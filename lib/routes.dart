import 'package:flutter/material.dart';

import 'chart/chart.dart';
import 'report/report.dart';

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
};
