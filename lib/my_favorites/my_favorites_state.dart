import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class MyFavoritesState extends Equatable {
  MyFavoritesState([List props = const []]) : super(props);
}

class ProjectLoading extends MyFavoritesState {
  @override
  String toString() => 'ProjectLoading';
}

class ProjectLoaded extends MyFavoritesState {
  final String context;

  ProjectLoaded({@required this.context})
      : assert(context != null),
        super([context]);

  @override
  String toString() => 'ProjectLoaded';
}

class ProjectError extends MyFavoritesState {
  final String message;

  ProjectError({this.message}) : super([message]);

  @override
  String toString() => 'ProjectError { message: $message }';
}
