import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class LuisState extends Equatable {
  LuisState([List props = const []]) : super(props);
}

class LuisUninitialized extends LuisState {
  @override
  String toString() => 'LuisUninitialized';
}

class UtteranceInput extends LuisState {
  final String luisProjectId;

  UtteranceInput({@required this.luisProjectId})
      : assert(luisProjectId != null),
        super([luisProjectId]);

  @override
  String toString() => 'UtteranceInput';
}

class UtteranceExecution extends LuisState {
  @override
  String toString() => 'UtteranceExecution';
}

class UtteranceExecutedWithUrl extends LuisState {
  final String url;

  UtteranceExecutedWithUrl({@required this.url})
      : assert(url != null),
        super([url]);

  @override
  String toString() => 'UtteranceExecutedWithUrl { url: $url }';
}

class LuisError extends LuisState {
  @override
  String toString() => 'LuisError';
}
