import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ReportState extends Equatable {
  ReportState([List props = const []]) : super(props);
}

class ReportIdle extends ReportState {
  @override
  String toString() => 'ReportUninitialized';
}

class ReportGeneration extends ReportState {
  @override
  String toString() => 'ReportGeneration';
}

class ReportGenerated extends ReportState {
  final Uint8List reportBytes;

  ReportGenerated({this.reportBytes}) : super([reportBytes]);

  @override
  String toString() => 'ReportGenerated';
}

class ReportError extends ReportState {
  @override
  String toString() => 'ReportError';
}
