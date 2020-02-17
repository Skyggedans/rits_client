import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectParametersState extends Equatable {
  ViewObjectParametersState([List props = const []]) : super(props);
}

class ViewObjectParametersInProgress extends ViewObjectParametersState {
  @override
  String toString() => 'ViewObjectParametersInProgress';
}

class ViewObjectParametersLoaded extends ViewObjectParametersState {
  final ViewObject viewObject;
  final List<ViewObjectParameter> parameters;

  ViewObjectParametersLoaded({
    this.viewObject,
    this.parameters,
  }) : super([viewObject, parameters]);

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
