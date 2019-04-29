import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'chart.dart';

class ChartScreen extends ViewObjectScreen<ChartBloc> {
  static String route = '/report';

  ChartBloc get viewObjectBloc => ChartBloc();

  ChartScreen({
    Key key,
    @required ViewObject viewObject,
    @required String userToken,
  }) : super(
          key: key,
          viewObject: viewObject,
          userToken: userToken,
        );

  @override
  State createState() => ChartScreenState();
}

class ChartScreenState extends ViewObjectScreenState {
  @override
  Widget buildOutputWidget(ViewObjectGenerated state) {
    return Image.memory(state.bytes);
  }
}
