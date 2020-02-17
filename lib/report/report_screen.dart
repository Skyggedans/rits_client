import 'package:flutter/material.dart';
import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'report.dart';

class ReportScreen extends ViewObjectScreen {
  static String route = '/report';

  ReportScreen({
    Key key,
    @required ViewObject viewObject,
  }) : super(key: key, viewObject: viewObject);

  @override
  State createState() => _ReportScreenState();
}

class _ReportScreenState
    extends ViewObjectScreenState<ReportBloc, ReportGenerated> {
  @override
  ReportBloc createBloc() {
    return ReportBloc(
      restClient: Provider.of<RestClient>(context),
      appContext: Provider.of<AppContext>(context),
    );
  }

  @override
  Widget buildOutputWidget(BuildContext context, ReportGenerated state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.bytes.lengthInBytes > 0) {
        PdfViewer.loadBytes(state.bytes);
      }
    });

    return Text('Report generated successfully');
  }
}
