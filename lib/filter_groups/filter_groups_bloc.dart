import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/filter_groups/filter_groups.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'filter_groups.dart';

class FilterGroupsBloc extends Bloc<FilterGroupsEvent, FilterGroupsState> {
  final RestClient restClient;
  final AppContext appContext;

  FilterGroupsBloc({@required this.restClient, @required this.appContext})
      : assert(restClient != null),
        assert(appContext != null),
        super();

  @override
  get initialState => FilterGroupsInProgress();

  @override
  Stream<FilterGroupsState> transformStates(Stream<FilterGroupsState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<FilterGroupsState> mapEventToState(FilterGroupsEvent event) async* {
    if (event is FetchFilterGroups) {
      yield FilterGroupsInProgress();

      try {
        final filterGroups = await _fetchFilterGroups();

        yield FilterGroupsLoaded(filterGroups: filterGroups);
      } on ApiError {
        yield FilterGroupsError(message: 'Unable to fetch filter groups');
      }
    }
  }

  Future<List<FilterGroup>> _fetchFilterGroups() async {
    final url =
        '${settings.backendUrl}/ObservedGroupFilter/${appContext.userToken}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);
    final filterGroups =
        body.map((filterGroup) => FilterGroup.fromJson(filterGroup)).toList();

    return filterGroups;
  }
}
