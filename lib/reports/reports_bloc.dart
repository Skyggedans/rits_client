import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/reports/report.dart';
import '../models/projects/projects.dart';
import 'reports.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final RestClient restClient;

  ReportsBloc({@required this.restClient});

  @override
  Stream<ReportsEvent> transform(Stream<ReportsEvent> events) {
    return (events as Observable<ReportsEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => ReportsUninitialized();

  @override
  Stream<ReportsState> mapEventToState(ReportsEvent event) async* {
    if (event is FetchReports) {
      try {
        if (currentState is ReportsUninitialized) {
          final reports = await _fetchReports(event.project, event.userToken);

          yield ReportsLoaded(reports: reports, userToken: event.userToken);

          return;
        }
      }
      catch (_) {
        yield ReportsError();
      }
    }
  }

  Future<List<Report>> _fetchReports(Project project, String userToken) async {
    final url = '${settings.backendUrl}/ViewObjects/$userToken/Reports';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((report) {
      return Report.fromJson(report);
    }).toList();
  }
}
