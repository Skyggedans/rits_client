import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:rits_client/models/kpi/kpi.dart';

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
  final String userToken;

  UtteranceInput({@required this.luisProjectId, @required this.userToken})
      : super([luisProjectId, userToken]);

  @override
  String toString() => 'UtteranceInput';
}

class UtteranceExecution extends LuisState {
  @override
  String toString() => 'UtteranceExecution';
}

class UtteranceExecutedWithUrl extends LuisState {
  final String url;

  UtteranceExecutedWithUrl({@required this.url}) : super([url]);

  @override
  String toString() => 'UtteranceExecutedWithUrl { info: $url }';
}

class UtteranceExecutedWithKpis extends LuisState {
  final List<Kpi> kpis;

  UtteranceExecutedWithKpis({@required this.kpis}) : super([kpis]);

  @override
  String toString() => 'UtteranceExecutedWithKpis { KPIs: $kpis.length }';
}

class LuisError extends LuisState {
  @override
  String toString() => 'LuisError';
}
