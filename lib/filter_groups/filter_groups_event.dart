import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/filter_groups/filter_groups.dart';

@immutable
abstract class FilterGroupsEvent extends Equatable {
  FilterGroupsEvent([List props = const []]) : super(props);
}

class FetchFilterGroups extends FilterGroupsEvent {
  @override
  String toString() => 'FetchFilterGroups';
}

class SaveSelectedFilterGroup extends FilterGroupsEvent {
  final FilterGroup filterGroup;

  SaveSelectedFilterGroup({@required this.filterGroup})
      : assert(filterGroup != null),
        super([filterGroup]);

  @override
  String toString() => 'SaveSelectedFilterGroup { group: ${filterGroup.name} }';
}
