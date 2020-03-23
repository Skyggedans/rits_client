import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class MatchingItemsSearchState extends Equatable {
  MatchingItemsSearchState([List props = const []]) : super(props);
}

class MatchingItemsIdle extends MatchingItemsSearchState {
  @override
  String toString() => 'MatchingItemsUninitialized';
}

class MatchingItemsSearchInProgress extends MatchingItemsSearchState {
  @override
  String toString() => 'MatchingItemsSearchInProgress';
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
