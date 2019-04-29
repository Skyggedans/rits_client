import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';

class ReportBloc extends ViewObjectBloc {
  ReportBloc() : super(restClient: RestClient());

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final reportBytes =
            await _getReportBytes(event.viewObject, event.userToken);

        yield ViewObjectIdle();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (reportBytes.lengthInBytes > 0) {
            PdfViewer.loadBytes(reportBytes);
          }
        });
      } catch (_) {
        yield ViewObjectError();
      }
    }
  }

  Future<Map<String, dynamic>> _getReportUrl(
      ViewObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/GenerateReportInternal/$userToken/${Uri.encodeFull(viewObject.name)}/pdf';
    final response = await restClient.get(url);

    return json.decode(response.body);
  }

  Future<Uint8List> _getReportBytes(
      ViewObject viewObject, String userToken) async {
    final url = await _getReportUrl(viewObject, userToken);
    final response = await restClient.get(url['Value']);

    return response.bodyBytes;
  }
}
