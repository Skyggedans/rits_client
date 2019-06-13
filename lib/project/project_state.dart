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

  ProjectLoaded({this.userToken}) : super([userToken]);

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
  @override
  String toString() => 'ProjectError';
}
