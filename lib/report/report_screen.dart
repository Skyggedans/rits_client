import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/view_object/view_object.dart';
import 'report.dart';

class ReportScreen extends ViewObjectScreen {
  static String route = '/report';

  ReportScreen({
    Key key,
    @required ViewObject viewObject,
  }) : super(
          key: key,
          viewObject: viewObject,
        );

  @override
  State createState() => _ReportScreenState();
}

class _ReportScreenState
    extends ViewObjectScreenState<ReportBloc, ReportGenerated> {
  ReportBloc viewObjectBloc = ReportBloc();

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
