import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/reports/reports.dart';
import '../models/report_parameters/report_parameters.dart';

@immutable
abstract class ReportParametersEvent extends Equatable {
  ReportParametersEvent([List props = const []]) : super(props);
}

class FetchReportParameters extends ReportParametersEvent {
  final Report report;
  final String userToken;

  FetchReportParameters({@required this.report, @required this.userToken})
      : super([report, userToken]);

  @override
  String toString() => 'FetchReportParameters';
}

class SaveReportParameter extends ReportParametersEvent {
  final Report report;
  final String userToken;
  final ReportParameter parameter;

  SaveReportParameter(
      {@required this.report,
      @required this.userToken,
      @required this.parameter})
      : super([report, userToken, parameter]);

  @override
  String toString() => 'UpdateReportParameters';
}
