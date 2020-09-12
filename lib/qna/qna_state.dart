import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:rits_client/models/qna/qna.dart';

@immutable
abstract class QnaState extends Equatable {
  QnaState([List props = const []]) : super(props);
}

class QnaLoading extends QnaState {
  @override
  String toString() => 'QnaUninitialized';
}

class QnaModulesLoaded extends QnaState {
  final List<String> modules;

  QnaModulesLoaded({@required this.modules}) : super([modules]);

  @override
  String toString() => 'QnaModulesLoaded { modules: ${modules} }';
}

class QnaPrompt extends QnaState {
  final String text;
  final bool isFirst;
  final List<QnaStatusItem> items;

  QnaPrompt({
    @required this.text,
    @required this.isFirst,
    this.items,
  }) : super([text, isFirst, items]);

  @override
  String toString() =>
      'QnaPrompt { text: ${text}, isFirst: ${isFirst}, items: ${items.length} }';
}

class QnaComplete extends QnaState {
  final String text;

  QnaComplete({
    @required this.text,
  }) : super([text]);

  @override
  String toString() => 'QnaComplete { text: ${text} }';
}

class QnaError extends QnaState {
  @override
  String toString() => 'QnaError';
}
