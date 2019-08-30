import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../settings.dart' as settings;
import '../utils/utils.dart';
import 'matching_items_search.dart';

class MatchingItemsSearchBloc
    extends Bloc<MatchingItemsSearchEvent, MatchingItemsSearchState> {
  final RestClient restClient;

  MatchingItemsSearchBloc({@required this.restClient})
      : assert(restClient != null);

  @override
  get initialState => MatchingItemsUninitialized();

  @override
  Stream<MatchingItemsSearchEvent> transform(
      Stream<MatchingItemsSearchEvent> events) {
    return (events as Observable<MatchingItemsSearchEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<MatchingItemsSearchState> mapEventToState(
      MatchingItemsSearchEvent event) async* {
    if (event is SearchMatchingItems) {
      yield MatchingItemsUninitialized();

      try {
        final items = await _searchItems(event.searchString, event.userToken);

        yield MatchingItemsLoaded(items: items);
      } on ApiError {
        yield MatchingItemsError(message: 'Unable to fetch matching items');
      }
    }
  }

  Future<List<String>> _searchItems(
      String searchString, String userToken) async {
    final url =
        '${settings.backendUrl}/MatchObservedItem/$userToken/${Uri.encodeFull(searchString)}';
    final response = await restClient.get(url);
    final body = json.decode(response.body);

    return body['ResultData'].cast<String>();
  }
}
