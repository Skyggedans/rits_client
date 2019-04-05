import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/reports/report.dart';

@immutable
abstract class ReportsState extends Equatable {
  ReportsState([List props = const []]) : super(props);
}

class ReportsUninitialized extends ReportsState {
  @override
  String toString() => 'ReportsUninitialized';
}

class ReportsError extends ReportsState {
  @override
  String toString() => 'ReportsError';
}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  final String userToken;

  ReportsLoaded({this.reports, this.userToken}) : super([reports, userToken]);

  ReportsLoaded copyWith({
    List<Report> reports,
    String userToken
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      userToken: userToken ?? this.userToken
    );
  }

  @override
  String toString() => 'ReportsLoaded { reports: ${reports.length} }';
}
