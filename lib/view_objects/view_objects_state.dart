import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectsState extends Equatable {
  ViewObjectsState([List props = const []]) : super(props);
}

class ViewObjectsUninitialized extends ViewObjectsState {
  @override
  String toString() => 'ViewObjectsUninitialized';
}

class ViewObjectsError extends ViewObjectsState {
  @override
  String toString() => 'ViewObjectsError';
}

class ViewObjectsLoaded extends ViewObjectsState {
  final List<ViewObject> viewObjects;

  ViewObjectsLoaded({@required this.viewObjects})
      : assert(viewObjects != null),
        super([viewObjects]);

  ViewObjectsLoaded copyWith({List<ViewObject> viewObjects}) {
    return ViewObjectsLoaded(viewObjects: viewObjects ?? this.viewObjects);
  }

  @override
  String toString() =>
      'ViewObjectsLoaded { viewObjects: ${viewObjects.length} }';
}
