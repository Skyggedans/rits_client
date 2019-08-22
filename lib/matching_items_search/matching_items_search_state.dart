import 'package:equatable/equatable.dart';

abstract class MatchingItemsSearchState extends Equatable {
  MatchingItemsSearchState([List props = const []]) : super(props);
}

class MatchingItemsUninitialized extends MatchingItemsSearchState {
  @override
  String toString() => 'MatchingItemsUninitialized';
}

class MatchingItemsLoaded extends MatchingItemsSearchState {
  final List<String> items;

  MatchingItemsLoaded({
    this.items,
  }) : super([items]);

  MatchingItemsLoaded copyWith({
    List<String> items,
  }) {
    return MatchingItemsLoaded(
      items: items ?? this.items,
    );
  }

  @override
  String toString() => 'MatchingItemsLoaded { items: ${items.length} }';
}

class MatchingItemSelected extends MatchingItemsSearchState {
  final String item;

  MatchingItemSelected({this.item}) : super([item]);
}

class MatchingItemsError extends MatchingItemsSearchState {
  final String message;

  MatchingItemsError({this.message}) : super([message]);

  @override
  String toString() => 'MatchingItemsError { message: $message }';
}
