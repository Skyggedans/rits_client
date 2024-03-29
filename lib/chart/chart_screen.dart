import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/auth/auth.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'chart.dart';

class ChartScreen extends ViewObjectScreen {
  static String route = '/chart';
  final AuthRepository authRepository;

  ChartScreen({
    Key key,
    @required this.authRepository,
    @required ViewObject viewObject,
  })  : assert(authRepository != null),
        assert(viewObject != null),
        super(key: key, viewObject: viewObject);

  @override
  State createState() => _ChartScreenState();
}

class _ChartScreenState
    extends ViewObjectScreenState<ChartBloc, ChartPresentation> {
  AuthRepository get _authRepository => (widget as ChartScreen).authRepository;

  @override
  ChartBloc createBloc() {
    return ChartBloc(
      restClient: Provider.of<RestClient>(context),
      appContext: Provider.of<AppContext>(context),
    );
  }

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
