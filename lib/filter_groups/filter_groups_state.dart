import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rits_client/models/filter_groups/filter_groups.dart';

@immutable
abstract class FilterGroupsState extends Equatable {
  FilterGroupsState([List props = const []]) : super(props);
}

class FilterGroupsInProgress extends FilterGroupsState {
  @override
  String toString() => 'FilterGroupsInProgress';
}

class FilterGroupsLoaded extends FilterGroupsState {
  final List<FilterGroup> filterGroups;

  FilterGroupsLoaded({
    this.filterGroups,
  }) : super([filterGroups]);

  @override
  String toString() =>
      'FilterGroupLevelsLoaded { levels: ${filterGroups.length} }';
}

class FilterGroupsError extends FilterGroupsState {
  final String message;

  FilterGroupsError({this.message}) : super([message]);

  @override
  String toString() => 'FilterGroupsError { message: $message }';
}
