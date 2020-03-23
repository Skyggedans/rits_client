import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'matching_items_search.dart';

class MatchingItemsSearchBloc
    extends Bloc<MatchingItemsSearchEvent, MatchingItemsSearchState> {
  final RestClient restClient;
  final AppContext appContext;

  MatchingItemsSearchBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super();

  @override
  get initialState => MatchingItemsIdle();

  @override
  Stream<MatchingItemsSearchState> transformStates(
      Stream<MatchingItemsSearchState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<MatchingItemsSearchState> mapEventToState(
      MatchingItemsSearchEvent event) async* {
    if (event is SearchMatchingItems) {
      yield MatchingItemsSearchInProgress();

      try {
        final items = await _searchItems(event.searchString);

        yield MatchingItemsLoaded(items: items);
      } on ApiError {
        yield MatchingItemsError(message: 'Unable to fetch matching items');
      }
    }
  }

  Future<List<String>> _searchItems(String searchString) async {
    final url =
        '${settings.backendUrl}/MatchObservedItem/${appContext.userToken}/${Uri.encodeFull(searchString)}';
    final response = await restClient.get(url);
    final body = json.decode(response.body) as Map<String, dynamic>;

    return List<String>.from(body['ResultData'] as List);
  }
}
