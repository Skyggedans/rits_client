import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/projects/projects.dart';

@immutable
abstract class LuisEvent extends Equatable {
  LuisEvent([List props = const []]) : super(props);
}

class LoadLuisProject extends LuisEvent {
  final Project project;
  final String userToken;

  LoadLuisProject(this.project, this.userToken) : super([project, userToken]);

  @override
  String toString() => 'LoadLuisProject { project: ${project.name} }';
}

class ExecuteUtterance extends LuisEvent {
  final String utteranceText;
  final String luisProjectId;
  final String userToken;

  ExecuteUtterance({
    @required this.utteranceText,
    @required this.luisProjectId,
    @required this.userToken,
  }) : super([utteranceText, luisProjectId, userToken]);

  @override
  String toString() =>
      'ExecuteUtterance { text: $utteranceText, luisProjectId: $luisProjectId }';
}
