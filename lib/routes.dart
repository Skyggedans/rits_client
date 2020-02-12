import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_object.dart';

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
          viewObject: args['viewObject'] as ViewObject,
          userToken: args['userToken'] as String,
        );
      },
      ChartScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return ChartScreen(
          authRepository: authRepository,
          viewObject: args['viewObject'] as ViewObject,
          userToken: args['userToken'] as String,
        );
      },
      TabularDataScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return TabularDataScreen(
          viewObject: args['viewObject'] as ViewObject,
          userToken: args['userToken'] as String,
        );
      },
      KpiScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return KpiScreen(
          viewObject: args['viewObject'] as ViewObject,
          userToken: args['userToken'] as String,
        );
      },
      AssociatedDataItemScreen.route: (BuildContext context) {
        final dynamic args = ModalRoute.of(context).settings.arguments;

        return AssociatedDataItemScreen(
          viewObject: args['viewObject'] as ViewObject,
          userToken: args['userToken'] as String,
        );
      },
    };

    return routes;
  }

  // Function(BuildContext) _generateRoute(ViewObjectScreen viewObjectScreen) {
  //       final func = (BuildContext context) {
  //         final dynamic args = ModalRoute.of(context).settings.arguments;

  //         return (
  //           authRepository: authRepository,
  //           viewObject: args['viewObject'] as ViewObject,
  //           userToken: args['userToken'] as String,
  //         );

  //       };

  //       return func;
  //     }
}
