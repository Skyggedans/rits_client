import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'report.dart';

class ReportScreen extends ViewObjectScreen {
  static String route = '/report';

  ReportScreen({
    Key key,
    @required ViewObject viewObject,
    @required String userToken,
  }) : super(
          key: key,
          viewObject: viewObject,
          userToken: userToken,
        );

  @override
  State createState() => _ReportScreenState();
}

class _ReportScreenState
    extends ViewObjectScreenState<ReportBloc, ReportGenerated> {
  final viewObjectBloc = ReportBloc();

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
