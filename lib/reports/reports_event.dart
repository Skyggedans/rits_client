import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/projects/projects.dart';

@immutable
abstract class ReportsEvent extends Equatable {
  ReportsEvent([List props = const []]) : super(props);
}

class FetchReports extends ReportsEvent {
  final Project project;
  final String userToken;

  FetchReports({this.project, this.userToken}) : super([project, userToken]);

  @override
  String toString() => 'FetchReports';
}
