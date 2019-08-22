import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MatchingItemsSearchEvent extends Equatable {
  MatchingItemsSearchEvent([List props = const []]) : super(props);
}

class SearchMatchingItems extends MatchingItemsSearchEvent {
  final String searchString;
  final String userToken;

  SearchMatchingItems({@required this.searchString, @required this.userToken})
      : assert(searchString != null),
        assert(userToken != null);

  @override
  String toString() => 'SearchMatchingItems';
}
