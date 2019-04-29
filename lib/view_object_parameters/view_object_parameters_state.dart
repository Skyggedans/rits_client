import 'package:equatable/equatable.dart';

import '../models/reports/reports.dart';
import '../models/view_objects/view_objects.dart';

abstract class ViewObjectParametersState extends Equatable {
  ViewObjectParametersState([List props = const []]) : super(props);
}

class ViewObjectParametersInProgress extends ViewObjectParametersState {
  @override
  String toString() => 'ViewObjectParametersInProgress';
}

class ViewObjectParametersLoaded extends ViewObjectParametersState {
  final ViewObject viewObject;
  final String userToken;
  final List<ViewObjectParameter> parameters;

  ViewObjectParametersLoaded({
    this.viewObject,
    this.userToken,
    this.parameters,
  }) : super([viewObject, userToken, parameters]);

  ViewObjectParametersLoaded copyWith({List<ViewObjectParameter> parameters}) {
    return ViewObjectParametersLoaded(
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() =>
      'ViewObjectParametersLoaded { parameters: ${parameters.length} }';
}

class ViewObjectParametersError extends ViewObjectParametersState {
  @override
  String toString() => 'ReportParametersError';
}
