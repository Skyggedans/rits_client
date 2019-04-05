import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/reports/reports.dart';

@immutable
abstract class ReportEvent extends Equatable {
  ReportEvent([List props = const []]) : super(props);
}

class ViewReport extends ReportEvent {
  final Report report;
  final String userToken;

  ViewReport(this.report, this.userToken) : super([report, userToken]);

  @override
  String toString() => 'ViewReport { reprot: ${report.name} }';
}
