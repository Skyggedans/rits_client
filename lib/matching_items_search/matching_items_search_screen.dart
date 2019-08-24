import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rw_help/rw_help.dart';

import '../utils/utils.dart';
import '../models/projects/projects.dart';
import 'matching_items_search.dart';

class MatchingItemsSearchScreen extends StatefulWidget {
  final String searchString;

  MatchingItemsSearchScreen({
    Key key,
    @required this.searchString,
  }) : assert(searchString != null);

  @override
  State createState() => _MatchingItemsSearchScreenState();
}

class _MatchingItemsSearchScreenState extends State<MatchingItemsSearchScreen> {
  final _matchingItemsSearchBloc =
      MatchingItemsSearchBloc(restClient: RestClient());

  String get _searchString => widget.searchString;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_matchingItemsSearchBloc.currentState ==
        _matchingItemsSearchBloc.initialState) {
      final projectContext = Provider.of<ProjectContext>(context);

      _matchingItemsSearchBloc.dispatch(SearchMatchingItems(
        searchString: _searchString,
        userToken: projectContext.userToken,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searching for \'${_searchString}\''),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _matchingItemsSearchBloc,
          builder: (BuildContext context, MatchingItemsSearchState state) {
            if (state is MatchingItemsUninitialized) {
              return CircularProgressIndicator();
            } else if (state is MatchingItemsLoaded) {
              return _buildItems(context, state);
            } else if (state is MatchingItemsError) {
              return Text(state.message);
            }
          },
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context, MatchingItemsLoaded state) {
    final items = state.items;

    if (items.length > 0) {
      final itemRange = items.length == 1 ? '1' : '1-${items.length}';

      RwHelp.setCommands(['Say "Select Result ${itemRange}"']);
    } else {
      RwHelp.setCommands([]);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return InkWell(
          child: Semantics(
            button: true,
            value: 'Select Result ${index + 1}',
            child: ListTile(
              leading: Text('${index + 1}'),
              title: Text(item),
            ),
            onTap: () {
              Navigator.pop(context, item);
            },
          ),
          onTap: () {
            Navigator.pop(context, item);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    RwHelp.setCommands([]);
    super.dispose();
  }
}
