import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FilterGroupsEvent extends Equatable {
  FilterGroupsEvent([List props = const []]) : super(props);
}

class FetchFilterGroups extends FilterGroupsEvent {
  @override
  String toString() => 'FetchFilterGroups';
}
