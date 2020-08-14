import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/filter_groups/filter.dart';
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
  final String content;

  SetContextFromBarCode({@required this.content})
      : assert(content != null),
        super([content]);

  @override
  String toString() => 'SetContextFromString { context: $content }';
}

class SetContextFromSearch extends ProjectEvent {
  final String result;

  SetContextFromSearch({@required this.result})
      : assert(result != null),
        super([result]);

  @override
  String toString() => 'SetContextFromSearch { context: $result }';
}

class SetContextFromFilter extends ProjectEvent {
  final Filter filter;

  SetContextFromFilter({@required this.filter})
      : assert(filter != null),
        super([filter]);

  @override
  String toString() => 'SetContextFromFilter { filter: $filter.name }';
}

class TakePhoto extends ProjectEvent {
  @override
  String toString() => 'TakePhoto';
}

class RecordVideo extends ProjectEvent {
  @override
  String toString() => 'RecordVideo';
}
