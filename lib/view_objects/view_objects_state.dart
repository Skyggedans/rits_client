import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/view_objects/view_objects.dart';

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

  ViewObjectsLoaded({this.viewObjects}) : super([viewObjects]);

  ViewObjectsLoaded copyWith({List<ViewObject> viewObjects}) {
    return ViewObjectsLoaded(
      viewObjects: viewObjects ?? this.viewObjects,
    );
  }

  @override
  String toString() =>
      'ViewObjectsLoaded { viewObjects: ${viewObjects.length} }';
}
