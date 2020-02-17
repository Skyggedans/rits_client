import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/filter_groups/filter_groups.dart';
import 'package:rits_client/utils/utils.dart';

import 'filter_groups.dart';

class FilterGroupsScreen extends StatefulWidget {
  @override
  State createState() => _FilterGroupsScreenState();
}

class _FilterGroupsScreenState extends State<FilterGroupsScreen> {
  FilterGroupsBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = FilterGroupsBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(FetchFilterGroups());
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Groups'),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _bloc,
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
        builder: (context) =>
            FilterGroupsSelectionScreen(filterGroups: levelGroups),
      ),
    ) as FilterGroup;

    if (selectedFilterGroup != null) {
      _bloc.add(SaveSelectedFilterGroup(filterGroup: selectedFilterGroup));
    }
  }
}
