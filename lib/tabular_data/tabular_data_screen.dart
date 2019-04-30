import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'tabular_data.dart';

class TabularDataScreen extends ViewObjectScreen {
  static String route = '/tabular_data';

  TabularDataScreen({
    Key key,
    @required ViewObject viewObject,
    @required String userToken,
  }) : super(
          key: key,
          viewObject: viewObject,
          userToken: userToken,
        );

  @override
  State createState() => _TabularDataScreenState();
}

class _TabularDataScreenState extends ViewObjectScreenState {
  ViewObjectBloc viewObjectBloc = TabularDataBloc();

  @override
  Widget buildOutputWidget(ViewObjectGenerated state) {
    final List<dynamic> rows = state.data;

    if (rows.length > 0) {
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
              separatorBuilder: (context, int) {
                return Divider(
                  color: Colors.black,
                );
              },
              itemBuilder: (context, index) {
                final Map<String, dynamic> row = rows[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: row.keys.toList().map((prop) {
                    return Expanded(
                      child: Text(
                        row[prop] ?? '',
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
