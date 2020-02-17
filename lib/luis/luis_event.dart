import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LuisEvent extends Equatable {
  LuisEvent([List props = const []]) : super(props);
}

class LoadLuisProject extends LuisEvent {
  @override
  String toString() => 'LoadLuisProject';
}

class ExecuteUtterance extends LuisEvent {
  final String utteranceText;
  final String luisAppId;

  ExecuteUtterance({
    @required this.utteranceText,
    @required this.luisAppId,
  }) : super([utteranceText, luisAppId]);

  @override
  String toString() =>
      'ExecuteUtterance { text: $utteranceText, luisProjectId: $luisAppId }';
}
