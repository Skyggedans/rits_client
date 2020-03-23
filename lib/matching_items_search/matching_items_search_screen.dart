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
  @override
  State createState() => _MatchingItemsSearchScreenState();
}

class _MatchingItemsSearchScreenState extends State<MatchingItemsSearchScreen> {
  MatchingItemsSearchBloc _bloc;
  bool isRealWearDevice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;

      _bloc = MatchingItemsSearchBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      );
    }
  }

  @override
  void dispose() {
    if (isRealWearDevice) {
      RwHelp.setCommands([]);
    }

    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.text,
              autofocus: true,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.search),
                labelText: 'Search Item',
                alignLabelWithHint: true,
              ),
              onFieldSubmitted: (value) async {
                _bloc.add(SearchMatchingItems(searchString: value));
              },
            ),
            Expanded(
              child: BlocBuilder(
                bloc: _bloc,
                builder:
                    (BuildContext context, MatchingItemsSearchState state) {
                  if (state is MatchingItemsSearchInProgress) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is MatchingItemsLoaded) {
                    return _buildItems(context, state);
                  } else if (state is MatchingItemsError) {
                    return Center(child: Text(state.message));
                  }

                  return SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItems(BuildContext context, MatchingItemsLoaded state) {
    final items = state.items;

    if (items.isEmpty) {
      return Center(
        child: const Text('There are no matching items found'),
      );
    }

    if (isRealWearDevice) {
      if (items.isNotEmpty) {
        final itemRange = items.length == 1 ? '1' : '1-${items.length}';

        RwHelp.setCommands(['Say "Select Result $itemRange"']);
      } else {
        RwHelp.setCommands([]);
      }
    }

    return ListView.builder(
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
