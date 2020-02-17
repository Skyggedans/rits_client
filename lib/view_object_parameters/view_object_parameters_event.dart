import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectParametersEvent extends Equatable {
  ViewObjectParametersEvent([List props = const []]) : super(props);
}

class FetchViewObjectParameters<T extends ViewObject>
    extends ViewObjectParametersEvent {
  final T viewObject;

  FetchViewObjectParameters({@required this.viewObject})
      : assert(viewObject != null),
        super([viewObject]);

  @override
  String toString() => 'FetchViewObjectParameters';
}

class SaveViewObjectParameter<T extends ViewObject>
    extends ViewObjectParametersEvent {
  final T viewObject;
  final ViewObjectParameter parameter;

  SaveViewObjectParameter({
    @required this.viewObject,
    @required this.parameter,
  })  : assert(viewObject != null),
        assert(parameter != null),
        super([viewObject, parameter]);

  @override
  String toString() => 'SaveViewObjectParameter';
}
