import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

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
  final String userToken;

  ViewObjectsLoaded({this.viewObjects, this.userToken})
      : super([viewObjects, userToken]);

  ViewObjectsLoaded copyWith({List<ViewObject> viewObjects, String userToken}) {
    return ViewObjectsLoaded(
        viewObjects: viewObjects ?? this.viewObjects,
        userToken: userToken ?? this.userToken);
  }

  @override
  String toString() =>
      'ViewObjectsLoaded { viewObjects: ${viewObjects.length} }';
}
