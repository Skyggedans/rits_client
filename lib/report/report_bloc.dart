import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';
import 'report.dart';

class ReportBloc extends ViewObjectBloc {
  ReportBloc({@required RestClient restClient, @required AppContext appContext})
      : super(restClient: restClient, appContext: appContext);

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final reportBytes = await _getReportBytes(event.viewObject);

        if (reportBytes.lengthInBytes > 4 &&
            String.fromCharCodes(reportBytes.take(4)) == '%PDF') {
          yield ReportGenerated(bytes: reportBytes);

          return;
        }

        yield ReportFormatError();
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<Map<String, dynamic>> _getReportUrl(ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/GenerateReportInternal/${appContext.userToken}/${Uri.encodeFull(viewObject.name)}/pdf';
    final response = await restClient.get(url);

    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<Uint8List> _getReportBytes(ViewObject viewObject) async {
    final url = await _getReportUrl(viewObject);
    final response =
        await restClient.get((url['Value'] ?? url['URL']) as String);

    return response.bodyBytes;
  }
}
