import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/projects/projects.dart';

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
  final String userToken;

  ScanBarcode({@required this.userToken})
      : assert(userToken != null),
        super([userToken]);

  @override
  String toString() => 'ScanBarcode';
}

class SetContextFromBarCode extends MyFavoritesEvent {
  final String context;
  final String userToken;

  SetContextFromBarCode({@required this.context, @required this.userToken})
      : assert(context != null),
        assert(userToken != null),
        super([context, userToken]);

  @override
  String toString() => 'SetContextFromString { context: $context }';
}

class SetContextFromSearch extends MyFavoritesEvent {
  final String context;
  final String userToken;

  SetContextFromSearch({@required this.context, @required this.userToken})
      : assert(context != null),
        assert(userToken != null),
        super([context, userToken]);

  @override
  String toString() => 'SetContextFromSearch { context: $context }';
}

class TakePhoto extends MyFavoritesEvent {
  final String userToken;

  TakePhoto({@required this.userToken}) : super([userToken]);

  @override
  String toString() => 'TakePhoto';
}

class RecordVideo extends MyFavoritesEvent {
  final String userToken;

  RecordVideo({@required this.userToken}) : super([userToken]);

  @override
  String toString() => 'RecordVideo';
}
