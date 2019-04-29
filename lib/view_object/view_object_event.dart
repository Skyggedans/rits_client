import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectEvent extends Equatable {
  ViewObjectEvent([List props = const []]) : super(props);
}

class GenerateViewObject extends ViewObjectEvent {
  final ViewObject viewObject;
  final String userToken;

  GenerateViewObject(this.viewObject, this.userToken)
      : super([viewObject, userToken]);

  @override
  String toString() => 'GenerateViewObject { viewObject: ${viewObject.name} }';
}
