import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//import 'package:rits_client/login.dart';
import 'projects/projects.dart';
import 'view_objects/view_objects.dart';
import 'view_object/view_object.dart';
import 'chart/chart.dart';
import 'report/report.dart';

final routes = <String, WidgetBuilder>{
  //"/login": (BuildContext context) => Login(),
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
