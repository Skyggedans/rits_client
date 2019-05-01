import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'chart.dart';

class ChartScreen extends ViewObjectScreen {
  static String route = '/chart';

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
  State createState() => _ChartScreenState();
}

class _ChartScreenState
    extends ViewObjectScreenState<ChartBloc, ChartGenerated> {
  ChartBloc viewObjectBloc = ChartBloc();

  @override
  Widget buildOutputWidget(ChartGenerated state) {
    return Image.memory(state.bytes);
  }
}
