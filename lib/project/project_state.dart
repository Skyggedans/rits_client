import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ProjectState extends Equatable {
  ProjectState([List props = const []]) : super(props);
}

class ProjectUninitialized extends ProjectState {
  @override
  String toString() => 'ProjectUninitialized';
}

class ProjectLoaded extends ProjectState {
  final String userToken;

  ProjectLoaded({this.userToken}) : super([userToken]);

  @override
  String toString() => 'ProjectLoaded';
}

class ProjectError extends ProjectState {
  @override
  String toString() => 'ProjectError';
}
