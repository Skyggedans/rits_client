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
    _bloc?.close();
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
          cubit: _bloc,
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
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: state.filterGroups.length,
      itemBuilder: (context, index) {
        final filterGroup = state.filterGroups[index];

        return InkWell(
          child: Semantics(
            button: true,
            value: filterGroup.name,
            child: Card(
              child: ListTile(
                title: Text(filterGroup.name),
                subtitle: Text(filterGroup.filters
                    .map((filter) => filter.displayName)
                    .join(', ')),
              ),
            ),
            onTap: () => _onGroupTap(context, filterGroup),
          ),
          onTap: () => _onGroupTap(context, filterGroup),
        );
      },
    );
  }

  void _onGroupTap(BuildContext context, FilterGroup filterGroup) async {
    final selectedFilter = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FilterGroupsSelectionScreen(filterGroup: filterGroup),
      ),
    ) as Filter;

    if (selectedFilter != null) {
      Navigator.pop(context, selectedFilter);
    }
  }
}
