import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../../models/report_parameters/report_parameters.dart';

@immutable
abstract class SelectionEvent extends Equatable {
  SelectionEvent([List props = const []]) : super(props);
}

class FetchSelectionOptions extends SelectionEvent {
  final ReportParameter param;
  final String userToken;

  FetchSelectionOptions({@required this.param, @required this.userToken})
      : super([param, userToken]);

  @override
  String toString() => 'FetchSelectionOptions';
}

class UpdateSelection<T> extends SelectionEvent {
  final T option;

  UpdateSelection({@required this.option}) : super([option]);

  @override
  String toString() => 'UpdateSelection';
}
