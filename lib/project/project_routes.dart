import 'package:flutter/material.dart';

import 'package:rits_client/associated_data_item/associated_data_item.dart';
import 'package:rits_client/chart/chart.dart';
import 'package:rits_client/kpi/kpi.dart';
import 'package:rits_client/report/report.dart';
import 'package:rits_client/tabular_data/tabular_data.dart';

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
