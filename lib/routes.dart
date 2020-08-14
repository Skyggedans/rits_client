import 'package:flutter/material.dart';
import 'package:rits_client/models/view_objects/view_object.dart';

import 'associated_data_item/associated_data_item.dart';
import 'chart/chart.dart';
import 'kpi/kpi.dart';
import 'report/report.dart';
import 'tabular_data/tabular_data.dart';

class Routes {
  static Map<String, WidgetBuilder> get() {
    final reportScreenBuilder = (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return ReportScreen(viewObject: args['viewObject'] as ViewObject);
    };

    final chartScreenBuilder = (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return ChartScreen(viewObject: args['viewObject'] as ViewObject);
    };

    final tabularDataScreenBuilder = (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return TabularDataScreen(viewObject: args['viewObject'] as ViewObject);
    };

    final kpiScreenBuilder = (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return KpiScreen(viewObject: args['viewObject'] as ViewObject);
    };

    final associatedDataScreenBuilder = (BuildContext context) {
      final dynamic args = ModalRoute.of(context).settings.arguments;

      return AssociatedDataItemScreen(
          viewObject: args['viewObject'] as ViewObject);
    };

    final routes = <String, WidgetBuilder>{
      '/Reports': reportScreenBuilder,
      ReportScreen.route: reportScreenBuilder,
      '/Charts': chartScreenBuilder,
      ChartScreen.route: chartScreenBuilder,
      TabularDataScreen.route: tabularDataScreenBuilder,
      KpiScreen.route: kpiScreenBuilder,
      '/BusinessObjects': associatedDataScreenBuilder,
      AssociatedDataItemScreen.route: associatedDataScreenBuilder,
      '/InputForm': (context) =>
          ErrorWidget.withDetails(message: 'Not implemented')
    };

    return routes;
  }
}
