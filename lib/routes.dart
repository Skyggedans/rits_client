import 'package:flutter/material.dart';
import 'package:rits_client/models/view_objects/view_object.dart';

import 'associated_data_item/associated_data_item.dart';
import 'chart/chart.dart';
import 'kpi/kpi.dart';
import 'report/report.dart';
import 'tabular_data/tabular_data.dart';

class Routes {
  static Map<String, WidgetBuilder> get() {
    final routes = <String, WidgetBuilder>{
      ReportScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return ReportScreen(viewObject: args['viewObject'] as ViewObject);
      },
      ChartScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return ChartScreen(viewObject: args['viewObject'] as ViewObject);
      },
      TabularDataScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return TabularDataScreen(viewObject: args['viewObject'] as ViewObject);
      },
      KpiScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return KpiScreen(viewObject: args['viewObject'] as ViewObject);
      },
      AssociatedDataItemScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return AssociatedDataItemScreen(
            viewObject: args['viewObject'] as ViewObject);
      },
    };

    return routes;
  }
}
