import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/projects/projects.dart';

@immutable
abstract class ProjectEvent extends Equatable {
  ProjectEvent([List props = const []]) : super(props);
}

class LoadProject extends ProjectEvent {
  final Project project;

  LoadProject(this.project) : super([project]);

  @override
  String toString() => 'LoadProject { project: ${project.name} }';
}

class ScanBarcode extends ProjectEvent {
  @override
  String toString() => 'ScanBarcode';
}

class SetContextFromBarCode extends ProjectEvent {
  final String sessionContext;

  SetContextFromBarCode({@required this.sessionContext})
      : assert(sessionContext != null),
        super([sessionContext]);

  @override
  String toString() => 'SetContextFromString { context: $sessionContext }';
}

class SetContextFromSearch extends ProjectEvent {
  final String sessionContext;

  SetContextFromSearch({@required this.sessionContext})
      : assert(sessionContext != null),
        super([sessionContext]);

  @override
  String toString() => 'SetContextFromSearch { context: $sessionContext }';
}

class TakePhoto extends ProjectEvent {
  @override
  String toString() => 'TakePhoto';
}

class RecordVideo extends ProjectEvent {
  @override
  String toString() => 'RecordVideo';
}
