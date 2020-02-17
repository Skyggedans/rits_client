import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/utils/utils.dart';
import 'package:rw_help/rw_help.dart';

import 'matching_items_search.dart';

class MatchingItemsSearchScreen extends StatefulWidget {
  final String searchString;

  MatchingItemsSearchScreen({
    Key key,
    @required this.searchString,
  })  : assert(searchString != null),
        super(key: key);

  @override
  State createState() => _MatchingItemsSearchScreenState();
}

class _MatchingItemsSearchScreenState extends State<MatchingItemsSearchScreen> {
  MatchingItemsSearchBloc _bloc;

  String get _searchString => widget.searchString;
  bool isRealWearDevice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = MatchingItemsSearchBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(SearchMatchingItems(searchString: _searchString));
      ;

      isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;
    }
  }

  @override
  void dispose() {
    if (isRealWearDevice) {
      RwHelp.setCommands([]);
    }

    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searching for \'$_searchString\''),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, MatchingItemsSearchState state) {
            if (state is MatchingItemsUninitialized) {
              return CircularProgressIndicator();
            } else if (state is MatchingItemsLoaded) {
              return _buildItems(context, state);
            } else if (state is MatchingItemsError) {
              return Text(state.message);
            }

            return const Text('Unable to fetch results');
          },
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context, MatchingItemsLoaded state) {
    final items = state.items;

    if (isRealWearDevice) {
      if (items.isNotEmpty) {
        final itemRange = items.length == 1 ? '1' : '1-${items.length}';

        RwHelp.setCommands(['Say "Select Result $itemRange"']);
      } else {
        RwHelp.setCommands([]);
      }
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
}
