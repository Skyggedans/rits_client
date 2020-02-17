import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/projects/projects.dart';

@immutable
abstract class MyFavoritesEvent extends Equatable {
  MyFavoritesEvent([List props = const []]) : super(props);
}

class LoadProject extends MyFavoritesEvent {
  final Project project;

  LoadProject(this.project) : super([project]);

  @override
  String toString() => 'LoadProject { project: ${project.name} }';
}

class ScanBarcode extends MyFavoritesEvent {
  @override
  String toString() => 'ScanBarcode';
}

class SetContextFromBarCode extends MyFavoritesEvent {
  final String context;

  SetContextFromBarCode({@required this.context})
      : assert(context != null),
        super([context]);

  @override
  String toString() => 'SetContextFromString { context: $context }';
}

class SetContextFromSearch extends MyFavoritesEvent {
  final String context;

  SetContextFromSearch({@required this.context})
      : assert(context != null),
        super([context]);

  @override
  String toString() => 'SetContextFromSearch { context: $context }';
}

class TakePhoto extends MyFavoritesEvent {
  @override
  String toString() => 'TakePhoto';
}

class RecordVideo extends MyFavoritesEvent {
  @override
  String toString() => 'RecordVideo';
}
