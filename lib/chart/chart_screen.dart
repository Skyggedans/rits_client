import 'package:flutter/foundation.dart';
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
  // ignore: close_sinks
  final viewObjectBloc = ChartBloc();

  AuthRepository get _authRepository => (widget as ChartScreen).authRepository;

  @override
  Widget buildOutputWidget(BuildContext context, ChartPresentation state) {
    final uri = Uri.parse(state.url);
    final params = uri.queryParameters;
    final newParams = {'id_token': _authRepository.accessToken};

    newParams.addAll(params);

    final newUri = uri.replace(queryParameters: newParams);

    return WebviewScaffold(
      url: newUri.toString(),
      headers: {
        'Authorization': 'Bearer ${_authRepository.accessToken}',
      },
    );
  }
}
