import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectParametersEvent extends Equatable {
  ViewObjectParametersEvent([List props = const []]) : super(props);
}

class FetchViewObjectParameters extends ViewObjectParametersEvent {
  final ViewObject viewObject;
  final String userToken;

  FetchViewObjectParameters(
      {@required this.viewObject, @required this.userToken})
      : super([viewObject, userToken]);

  @override
  String toString() => 'FetchViewObjectParameters';
}

class SaveViewObjectParameter extends ViewObjectParametersEvent {
  final ViewObject viewObject;
  final String userToken;
  final ViewObjectParameter parameter;

  SaveViewObjectParameter({
    @required this.viewObject,
    @required this.userToken,
    @required this.parameter,
  }) : super([viewObject, userToken, parameter]);

  @override
  String toString() => 'SaveViewObjectParameter';
}
