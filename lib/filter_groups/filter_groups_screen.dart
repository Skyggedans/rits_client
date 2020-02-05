import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../models/filter_groups/filter_groups.dart';
import '../utils/utils.dart';
import 'filter_groups.dart';

class FilterGroupsScreen extends StatefulWidget {
  final String userToken;

  FilterGroupsScreen({
    Key key,
    @required this.userToken,
  }) : assert(userToken != null);

  @override
  State createState() => _FilterGroupsScreenState();
}

class _FilterGroupsScreenState extends State<FilterGroupsScreen> {
  final _filterGroupsBloc = FilterGroupsBloc(restClient: RestClient());

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _filterGroupsBloc.add(FetchFilterGroups(userToken: _userToken));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Groups'),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _filterGroupsBloc,
          builder: (BuildContext context, FilterGroupsState state) {
            if (state is FilterGroupsInProgress) {
              return CircularProgressIndicator();
            } else if (state is FilterGroupsLoaded) {
              return _buildFilterGroups(context, state);
            } else if (state is FilterGroupsError) {
              return Text(state.message);
            }

            return const Text('Unable to fetch filter groups');
          },
        ),
      ),
    );
  }

  Widget _buildFilterGroups(BuildContext context, FilterGroupsLoaded state) {
    final filterGroups = state.filterGroups;
    final levels = <int, List<FilterGroup>>{};

    final levelNames = {
      1: 'Country',
      2: 'Company',
      3: 'Order',
    };

    filterGroups.forEach((filterGroup) {
      levels.putIfAbsent(filterGroup.levelNumber, () => []);
      levels[filterGroup.levelNumber].add(filterGroup);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final levelNumber = levels.keys.toList()[index];
        final levelGroups = levels[levelNumber];
        final levelTitle = levelNames[levelNumber];

        return InkWell(
          child: Semantics(
            button: true,
            value: levelTitle,
            child: Card(
              child: ListTile(
                title: Text(levelTitle),
                subtitle: Text(levelGroups
                    //.where((filterGroup) => filterGroup.isActive)
                    .map((filterGroup) => filterGroup.name)
                    .join(', ')),
              ),
            ),
            onTap: () => _onLevelTap(context, levelGroups),
          ),
          onTap: () => _onLevelTap(context, levelGroups),
        );
      },
    );
  }

  void _onLevelTap(BuildContext context, List<FilterGroup> levelGroups) async {
    final selectedFilterGroup = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterGroupsSelectionScreen(
          userToken: _userToken,
          filterGroups: levelGroups,
        ),
      ),
    ) as FilterGroup;

    if (selectedFilterGroup != null) {
      _filterGroupsBloc.add(SaveSelectedFilterGroup(
        filterGroup: selectedFilterGroup,
        userToken: _userToken,
      ));
    }
  }
}
