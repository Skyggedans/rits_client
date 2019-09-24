import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:memoize/memoize.dart';
import 'package:rxdart/rxdart.dart';

import '../models/filter_groups/filter_groups.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'filter_groups.dart';

class FilterGroupsBloc extends Bloc<FilterGroupsEvent, FilterGroupsState> {
  final RestClient restClient;

  FilterGroupsBloc({@required this.restClient}) : assert(restClient != null);

  @override
  get initialState => FilterGroupsInProgress();

  @override
  Stream<FilterGroupsEvent> transform(Stream<FilterGroupsEvent> events) {
    return (events as Observable<FilterGroupsEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<FilterGroupsState> mapEventToState(FilterGroupsEvent event) async* {
    if (event is FetchFilterGroups) {
      yield FilterGroupsInProgress();

      try {
        final filterGroups = await _fetchFilterGroups(event.userToken);

        yield FilterGroupsLoaded(filterGroups: filterGroups);
      } on ApiError {
        yield FilterGroupsError(message: 'Unable to fetch filter groups');
      }
    } else if (event is SaveSelectedFilterGroup) {
      yield FilterGroupsInProgress();

      try {
        await _saveSelectedFilterGroup(
          event.filterGroup,
          event.userToken,
        );
      } on ApiError {
        yield FilterGroupsError(
            message: 'Unable to save selected filter group');
      }
    }
  }

  Future<List<FilterGroup>> _fetchFilterGroups(String userToken) async {
    final url = '${settings.backendUrl}/GroupFilter/$userToken';
    final response = await restClient.get(url);
    final Iterable<dynamic> body = json.decode(response.body);
    final getActiveFilterGroupsForLevelCached =
        memo2(_getActiveFilterGroupsForLevel);

    final futures = body.map((filterGroup) {
      final group = FilterGroup.fromJson(filterGroup);

      return getActiveFilterGroupsForLevelCached(
        group.levelNumber,
        userToken,
      ).then((filterGroupsForLevel) {
        final isActive = filterGroupsForLevel.contains(group.name);

        return group.copyWith(isActive: isActive);
      });

      //return Future.value(group.copyWith(isActive: group.name == 'alfred'));
    });

    final filterGroups = await Future.wait(futures);

    filterGroups.sort((group1, group2) {
      return group1.levelNumber < group2.levelNumber
          ? -1
          : (group1.levelNumber > group2.levelNumber ? 1 : 0);
    });

    return filterGroups;
  }

  Future<List<String>> _getActiveFilterGroupsForLevel(
      int levelNumber, String userToken) async {
    final url =
        '${settings.backendUrl}/GetActiveGroupFilter/$userToken/$levelNumber';
    final String response = await restClient.get(url) as String;

    return response?.split('|') ?? '';
  }

  Future<void> _saveSelectedFilterGroup(
    FilterGroup filterGroup,
    String userToken,
  ) async {
    final url =
        '${settings.backendUrl}/SetActiveGroupFilter/$userToken/${filterGroup.levelNumber}/${Uri.encodeFull(filterGroup.name)}';

    await restClient.get(url);
  }
}
