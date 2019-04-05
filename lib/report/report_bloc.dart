import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/reports/report.dart';
import 'report.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final RestClient restClient;

  ReportBloc({@required this.restClient});

  @override
  get initialState => ReportIdle();

  @override
  Stream<ReportEvent> transform(Stream<ReportEvent> events) {
    return (events as Observable<ReportEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<ReportState> mapEventToState(ReportEvent event) async* {
    if (event is ViewReport) {
      yield ReportGeneration();

      try {
          final reportBytes = await _getReportBytes(event.report, event.userToken);

          yield ReportIdle();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (reportBytes.lengthInBytes > 0) {
              PdfViewer.loadBytes(reportBytes);
            }
          });
      }
      catch (_) {
        yield ReportError();
      }
    }
  }

  Future<Map<String, dynamic>> _getReportUrl(Report report, String userToken) async {
    final url = '${settings.backendUrl}/GenerateReport/$userToken/${Uri.encodeFull(report.name)}/pdf';
    final response = await restClient.get(url);

    return json.decode(response.body);
  }

  Future<Uint8List> _getReportBytes(Report report, String userToken) async {
    final url = await _getReportUrl(report, userToken);
    final response = await restClient.get('https://appbuilder.rockwellits.com//ReportsJob/DDR636884179965084705.pdf' /*url['URL']*/);

    return response.bodyBytes;
  }
}
