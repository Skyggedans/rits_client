import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MatchingItemsSearchEvent extends Equatable {
  MatchingItemsSearchEvent([List props = const []]) : super(props);
}

class SearchMatchingItems extends MatchingItemsSearchEvent {
  final String searchString;

  SearchMatchingItems({@required this.searchString})
      : assert(searchString != null),
        super([searchString]);

  @override
  String toString() => 'SearchMatchingItems';
}
