import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectEvent extends Equatable {
  ViewObjectEvent([List props = const []]) : super(props);
}

class ReturnToViewObjectMainScreen extends ViewObjectEvent {
  @override
  String toString() => 'ReturnToViewObjectMainScreen';
}

class GenerateViewObject<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;
  final String userToken;

  GenerateViewObject(this.viewObject, this.userToken)
      : super([viewObject, userToken]);

  @override
  String toString() => 'GenerateViewObject { viewObject: ${viewObject.name} }';
}
