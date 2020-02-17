import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'tabular_data.dart';

enum RecordAction {
  CANCEL,
  EDIT,
  REMOVE,
}

class TabularDataScreen extends ViewObjectScreen {
  static String route = '/tabular_data';

  TabularDataScreen({
    Key key,
    @required ViewObject viewObject,
  })  : assert(viewObject != null),
        super(key: key, viewObject: viewObject);

  @override
  State createState() => _TabularDataScreenState();
}

class _TabularDataScreenState
    extends ViewObjectScreenState<TabularDataBloc, TabularDataGenerated> {
  @override
  TabularDataBloc createBloc() {
    return TabularDataBloc(
      restClient: Provider.of<RestClient>(context),
      appContext: Provider.of<AppContext>(context),
    );
  }

  @override
  Widget buildOutputWidget(BuildContext context, TabularDataGenerated state) {
    final rows = List<Map<String, dynamic>>.from(state.data);

    if (rows.isNotEmpty) {
      final List<String> columns = rows[0].keys.toList();

      return Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: columns.map((column) {
              return Expanded(
                child: Text(
                  column,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(10.0),
              itemCount: rows.length,
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.black,
                );
              },
              itemBuilder: (context, index) {
                final row = rows[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: row.keys.toList().map((prop) {
                    return Expanded(
                      child: Text(
                        (row[prop] ?? '').toString(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const Text('No data');
    }
  }
}
