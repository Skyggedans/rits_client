import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:meta/meta.dart';

import '../authentication/authentication.dart';
import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'chart.dart';

class ChartScreen extends ViewObjectScreen {
  static String route = '/chart';
  final AuthRepository authRepository;

  ChartScreen({
    Key key,
    @required this.authRepository,
    @required ViewObject viewObject,
    @required String userToken,
  })  : assert(authRepository != null),
        super(
          key: key,
          viewObject: viewObject,
          userToken: userToken,
        );

  @override
  State createState() => _ChartScreenState();
}

class _ChartScreenState
    extends ViewObjectScreenState<ChartBloc, ChartPresentation> {
  ChartBloc viewObjectBloc = ChartBloc();

  AuthRepository get _authRepository => (widget as ChartScreen).authRepository;

  @override
  Widget buildOutputWidget(ChartPresentation state) {
    return WebviewScaffold(
      url: state.url,
      headers: {'Authorization': 'Bearer ${_authRepository.accessToken}'},
    );
  }
}
