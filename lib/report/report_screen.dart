import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'report.dart';

class ReportScreen extends ViewObjectScreen<ReportBloc> {
  static String route = '/report';

  ReportBloc get viewObjectBloc => ReportBloc();

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
  State createState() => ReportScreenState();
}

class ReportScreenState extends ViewObjectScreenState {
  @override
  Widget buildOutputWidget(ViewObjectState state) {
    if (state is ViewObjectGenerated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.bytes.lengthInBytes > 0) {
          PdfViewer.loadBytes(state.bytes);
        }
      });
    }

    return Text('Report generated successfully');
  }
}
