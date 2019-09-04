import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/utils.dart';
import 'package:rits_client/view_object/view_object.dart';

class ReportBloc extends ViewObjectBloc {
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
            PdfViewer.loadBytes(reportBytes,
                config: PdfViewerConfig(
                    pageSnap: true, pageFling: true, enableSwipe: true));
          }
        });
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
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
    final response = await restClient.get(url['URL'] ?? url['Value']);

    return response.bodyBytes;
  }
}
