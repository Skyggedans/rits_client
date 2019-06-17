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
  final String userToken;
  final String hierarchyLevel;
  final String context;

  ProjectLoaded({@required this.userToken, this.hierarchyLevel, this.context})
      : super([userToken, hierarchyLevel, context]);

  @override
  String toString() => 'ProjectLoaded';
}

class ItemScanned extends ProjectState {
  final String itemInfo;

  ItemScanned({this.itemInfo}) : super([itemInfo]);

  @override
  String toString() => 'ItemScanned { info: $itemInfo }';
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError({this.message}) : super([message]);

  @override
  String toString() => 'ProjectError { message: $message }';
}
