import 'package:flutter/material.dart';

import 'associated_data_item/associated_data_item.dart';
import 'authentication/authentication.dart';
import 'chart/chart.dart';
import 'kpi/kpi.dart';
import 'report/report.dart';
import 'tabular_data/tabular_data.dart';

class Routes {
  static Map<String, WidgetBuilder> get({
    @required AuthRepository authRepository,
  }) {
    assert(authRepository != null);

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
          authRepository: authRepository,
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
      AssociatedDataItemScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return AssociatedDataItemScreen(
          viewObject: args['viewObject'],
          userToken: args['userToken'],
        );
      },
    };

    return routes;
  }
}
