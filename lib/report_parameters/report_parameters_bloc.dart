import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/reports/reports.dart';
import '../models/report_parameters/report_parameters.dart';
import 'report_parameters.dart';

class ReportParametersBloc
    extends Bloc<ReportParametersEvent, ReportParametersState> {
  final RestClient restClient;

  ReportParametersBloc({@required this.restClient});

  @override
  Stream<ReportParametersEvent> transform(
      Stream<ReportParametersEvent> events) {
    return (events as Observable<ReportParametersEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => ReportParametersInProgress();

  @override
  Stream<ReportParametersState> mapEventToState(
      ReportParametersEvent event) async* {
    if (event is FetchReportParameters) {
      yield ReportParametersInProgress();

      try {
        final params = await _fetchReportParams(event.report, event.userToken);

        yield ReportParametersLoaded(
            report: event.report,
            userToken: event.userToken,
            parameters: params);
      } catch (_) {
        yield ReportParametersError();
      }
    } else if (event is SaveReportParameter) {
      yield ReportParametersInProgress();

      try {
        await _saveReportParam(event.report, event.parameter, event.userToken);
        this.dispatch(FetchReportParameters(
            report: event.report, userToken: event.userToken));
      } catch (_) {
        yield ReportParametersError();
      }
    }
  }

  Future<List<ReportParameter>> _fetchReportParams(
      Report report, String userToken) async {
    final url =
        '${settings.backendUrl}/GetViewElementParameter/$userToken/${Uri.encodeFull(report.name)}/Reports';
    final response = await restClient.get(url);
    print(response.body);
    final List body = json.decode(response.body);

    List<ReportParameter> allParams = body.map((param) {
      return ReportParameter.fromJson(param);
    }).toList();

    allParams = allParams.fold(List<ReportParameter>(), (params, nextParam) {
      if (!nextParam.name.endsWith('SelectedItem')) {
        final selectionValueParam = allParams.firstWhere(
            (param) => param.name == '${nextParam.name}SelectedItem',
            orElse: () => null);

        if (selectionValueParam != null) {
          nextParam = nextParam.copyWith(
            viewItem: selectionValueParam.viewItem,
            itemType: selectionValueParam.itemType,
            value: selectionValueParam.value,
          );
        }

        params.add(nextParam);
      }

      return params;
    });

    return allParams;
  }

  Future<void> _saveReportParam(
      Report report, ReportParameter param, String userToken) async {
    final paramJson = param.toJson();
    final name = Uri.encodeFull(paramJson['ParameterName']);

    if (param.value is List<Filter>) {
      final url =
          '${settings.backendUrl}/UpdateCategoryFilterData/$userToken/$name';

      await restClient.post(url,
          body: json.encode(paramJson['ParameterValue']));
    } else {
      final value = Uri.encodeFull(paramJson['ParameterValue']);
      final url =
          '${settings.backendUrl}/SetParameterValue/$userToken/$name/$value';

      await restClient.get(url);
    }
  }
}
