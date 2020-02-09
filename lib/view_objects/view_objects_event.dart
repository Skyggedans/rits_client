import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/projects/projects.dart';

@immutable
abstract class ViewObjectsEvent extends Equatable {
  ViewObjectsEvent([List props = const []]) : super(props);
}

class FetchViewObjects extends ViewObjectsEvent {
  final Project project;
  final String type;
  final String userToken;
  final String hierarchyLevel;
  final bool favorite;

  FetchViewObjects({
    @required this.project,
    @required this.type,
    @required this.userToken,
    this.hierarchyLevel,
    this.favorite,
  }) : super([project, type, userToken, hierarchyLevel, favorite]);

  @override
  String toString() => 'FetchViewObjects';
}
