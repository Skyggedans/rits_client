import 'package:equatable/equatable.dart';
import 'package:rits_client/models/qna/qna.dart';

abstract class QnaEvent extends Equatable {
  QnaEvent([List props = const []]) : super(props);
}

class LoadQnaModules extends QnaEvent {
  @override
  String toString() => 'GetQnaModules';
}

class BeginQnaSession extends QnaEvent {
  final String name;

  BeginQnaSession(this.name) : super([name]);

  @override
  String toString() => 'BeginQnaSession { name: ${name} }';
}

class QnaBack extends QnaEvent {
  final String name;

  QnaBack(this.name) : super([name]);

  @override
  String toString() => 'QnaBack { name: ${name} }';
}

class QnaRestart extends QnaEvent {
  final String name;

  QnaRestart(this.name) : super([name]);

  @override
  String toString() => 'QnaRestart { name: ${name} }';
}

class PullQnaStatus extends QnaEvent {
  final String name;

  PullQnaStatus(this.name) : super([name]);

  @override
  String toString() => 'PullQnaStatus { name: ${name} }';
}

class GetQnaPrompt extends QnaEvent {
  final String name;
  final bool initial;

  GetQnaPrompt(this.name, {this.initial = false}) : super([name, initial]);

  @override
  String toString() => 'QnaPrompt { name: ${name}, initial: ${initial} }';
}

class SendQnaResponse extends QnaEvent {
  final String name;
  final bool response;

  SendQnaResponse(this.name, this.response)
      : assert(name != null),
        assert(response != null),
        super([name, response]);

  @override
  String toString() => 'QnaRestart { name: ${name}, response: ${response} }';
}

class QnaItemSelected extends QnaEvent {
  final QnaStatusItem item;

  QnaItemSelected(this.item) : super([item]);

  @override
  String toString() => 'QnaItemSelected { item: ${item} }';
}
