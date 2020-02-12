import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ProjectState extends Equatable {
  ProjectState([List props = const []]) : super(props);
}

class ProjectLoading extends ProjectState {
  @override
  String toString() => 'ProjectLoading';
}

class ProjectLoaded extends ProjectState {
  @override
  String toString() => 'ProjectLoaded';
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError({this.message}) : super([message]);

  @override
  String toString() => 'ProjectError { message: $message }';
}
