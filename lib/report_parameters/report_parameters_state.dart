import 'package:equatable/equatable.dart';

import '../models/reports/reports.dart';
import '../models/report_parameters/report_parameters.dart';


abstract class ReportParametersState extends Equatable {
  ReportParametersState([List props = const []]) : super(props);
}

class ReportParametersInProgress extends ReportParametersState {
  @override
  String toString() => 'ReportParametersUninitialized';
}

class ReportParametersLoaded extends ReportParametersState {
  final Report report;
  final String userToken;
  final List<ReportParameter> parameters;

  ReportParametersLoaded({
    this.report,
    this.userToken,
    this.parameters,
  }) : super([report, userToken, parameters]);

  ReportParametersLoaded copyWith({List<ReportParameter> parameters}) {
    return ReportParametersLoaded(
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() =>
      'ReportParametersLoaded { parameters: ${parameters.length} }';
}

class ReportParametersError extends ReportParametersState {
  @override
  String toString() => 'ReportParametersError';
}
