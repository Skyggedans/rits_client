import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'matching_items_search.dart';

class MatchingItemsSearchBloc
    extends Bloc<MatchingItemsSearchEvent, MatchingItemsSearchState> {
  final RestClient restClient;

  MatchingItemsSearchBloc({@required this.restClient})
      : assert(restClient != null);

  @override
  get initialState => MatchingItemsUninitialized();

  @override
  Stream<MatchingItemsSearchState> transformStates(
      Stream<MatchingItemsSearchState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
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
    final body = json.decode(response.body) as Map<String, dynamic>;

    return List<String>.from(body['ResultData'] as List);
  }
}
