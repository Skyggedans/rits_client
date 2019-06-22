import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'associated_data_item.dart';

enum RecordAction {
  CANCEL,
  EDIT,
  REMOVE,
}

class AssociatedDataItemScreen extends ViewObjectScreen {
  static String route = '/associated_data';

  AssociatedDataItemScreen({
    Key key,
    @required ViewObject viewObject,
    @required String userToken,
  }) : super(
          key: key,
          viewObject: viewObject,
          userToken: userToken,
        );

  @override
  State createState() => _AssociatedDataItemScreenState();
}

class _AssociatedDataItemScreenState extends ViewObjectScreenState<
    AssociatedDataItemBloc, AssociatedDataItemGenerated> {
  AssociatedDataItemBloc viewObjectBloc = AssociatedDataItemBloc();

  @override
  Widget buildOutputWidget(AssociatedDataItemGenerated state) {
    final columns = state.table.columns;
    final rows = state.table.rows;

    if (rows.length > 0) {
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

                return InkWell(
                  child: Semantics(
                    button: true,
                    value: 'Record $index',
                    onTap: () {
                      _showRecordDialog(context, row, index);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: columns.map((prop) {
                        return Expanded(
                          child: Text(
                            (row[prop] ?? '').toString(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  onTap: () {
                    _showRecordDialog(context, row, index);
                  },
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

  Future<RecordAction> _showRecordDialog(
      BuildContext context, dynamic row, int index) async {
    return showDialog<RecordAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Record $index'),
          content: const Text('Select required action'),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(RecordAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('EDIT'),
              onPressed: () {
                Navigator.of(context).pop(RecordAction.EDIT);
              },
            ),
            FlatButton(
              child: const Text('REMOVE'),
              onPressed: () {
                Navigator.of(context).pop(RecordAction.REMOVE);
              },
            ),
          ],
        );
      },
    );
  }
}
