import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/filter_groups/filter_groups.dart';

abstract class FilterGroupsEvent extends Equatable {
  FilterGroupsEvent([List props = const []]) : super(props);
}

class FetchFilterGroups extends FilterGroupsEvent {
  final String userToken;

  FetchFilterGroups({@required this.userToken})
      : assert(userToken != null),
        super([userToken]);

  @override
  String toString() => 'FetchFilterGroups';
}

class SaveSelectedFilterGroup extends FilterGroupsEvent {
  final FilterGroup filterGroup;
  final String userToken;

  SaveSelectedFilterGroup({
    @required this.filterGroup,
    @required this.userToken,
  })  : assert(filterGroup != null),
        assert(userToken != null),
        super([filterGroup, userToken]);

  @override
  String toString() => 'SaveSelectedFilterGroup { group: ${filterGroup.name} }';
}
