import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

import 'package:rits_client/authentication/authentication.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/view_object/view_object.dart';
import 'chart.dart';

class ChartScreen extends ViewObjectScreen {
  static String route = '/chart';

  ChartScreen({
    Key key,
    @required ViewObject viewObject,
  }) : super(
          key: key,
          viewObject: viewObject,
        );

  @override
  State createState() => _ChartScreenState();
}

class _ChartScreenState
    extends ViewObjectScreenState<ChartBloc, ChartPresentation> {
  ChartBloc viewObjectBloc = ChartBloc();

  @override
  Widget buildOutputWidget(BuildContext context, ChartPresentation state) {
    final authRepository = Provider.of<AuthRepository>(context);

    return WebviewScaffold(
      // debuggingEnabled: true,
      // clearCache: true,
      // appCacheEnabled: false,
      // appBar: AppBar(
      //   actions: <Widget>[
      //     RaisedButton(
      //       child: const Text('Reload'),
      //       onPressed: () {
      //         context.visitChildElements((child) {
      //           if (child.widget is WebviewScaffold) {
      //             ((child as StatefulElement).state as dynamic)
      //                 .reloadUrl(state.url);
      //           }
      //         });
      //       },
      //     )
      //   ],
      // ),
      url: state.url,
      headers: {
        'Authorization': 'Bearer ${authRepository.accessToken}',
      },
    );
  }
}
