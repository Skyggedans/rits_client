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
    } else if (event is SaveSelectedFilterGroup) {
      yield FilterGroupsInProgress();

      try {
        await _saveSelectedFilterGroup(event.filterGroup);
      } on ApiError {
        yield FilterGroupsError(
            message: 'Unable to save selected filter group');
      }
    }
  }

  Future<List<FilterGroup>> _fetchFilterGroups() async {
    final url = '${settings.backendUrl}/GroupFilter/${appContext.userToken}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);
    // final getActiveFilterGroupsForLevelCached =
    //     memo2(_getActiveFilterGroupsForLevel);

    // final futures = body.map((filterGroup) {
    //   final group = FilterGroup.fromJson(filterGroup);

    //   return getActiveFilterGroupsForLevelCached(
    //     group.levelNumber,
    //     userToken,
    //   ).then((filterGroupsForLevel) {
    //     final isActive = filterGroupsForLevel.contains(group.name);

    //     return group.copyWith(isActive: isActive);
    //   });

    //   //return Future.value(group.copyWith(isActive: group.name == 'alfred'));
    // });

    // final filterGroups = await Future.wait(futures);

    final filterGroups =
        body.map((filterGroup) => FilterGroup.fromJson(filterGroup)).toList();

    // filterGroups.sort((group1, group2) {
    //   return group1.levelNumber < group2.levelNumber
    //       ? -1
    //       : (group1.levelNumber > group2.levelNumber ? 1 : 0);
    // });

    return filterGroups;
  }

  // ignore: unused_element
  Future<List<String>> _getActiveFilterGroupsForLevel(int levelNumber) async {
    final url =
        '${settings.backendUrl}/GetActiveGroupFilter/${appContext.userToken}/$levelNumber';
    final String response = await restClient.get(url) as String;

    return response?.split('|') ?? [];
  }

  Future<void> _saveSelectedFilterGroup(FilterGroup filterGroup) async {
    final url =
        '${settings.backendUrl}/SetActiveGroupFilter/${appContext.userToken}/${filterGroup.levelNumber}/${Uri.encodeFull(filterGroup.name)}';

    await restClient.get(url);
  }
}
