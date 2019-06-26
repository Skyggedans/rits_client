import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../models/associated_data/associated_data.dart';
import '../models/view_objects/view_objects.dart';
import '../row_editor/row_editor_screen.dart';
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
  void initState() {
    super.initState();
    viewObjectBloc.dispatch(GenerateViewObject(viewObject, userToken));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: viewObjectBloc,
      builder: (BuildContext context, ViewObjectState state) {
        Widget bodyChild;
        String title = viewObject.title ?? viewObject.name;

        if (state is ViewObjectGeneration) {
          bodyChild = CircularProgressIndicator();
        } else if (state is AssociatedDataItemGenerated) {
          title += '.${state.table.container.name}';
          bodyChild = buildOutputWidget(state);
        } else if (state is NoActiveContainerError) {
          bodyChild = const Text('There is no active container');
        } else if (state is ViewObjectError) {
          bodyChild = const Text('Failed to generate associated data item');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: state is AssociatedDataItemGenerated
                ? <Widget>[
                    FlatButton(
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          Text(
                            'NEW RECORD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _onNewRecord(
                            context, state.columnDefinitions, state.table);
                      },
                    ),
                    FlatButton(
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          Text(
                            'SAVE DATA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        viewObjectBloc.dispatch(SaveRows(
                          table: state.table,
                          viewObject: state.viewObject,
                          userToken: state.userToken,
                        ));
                      },
                    ),
                  ]
                : null,
          ),
          body: Center(child: bodyChild),
        );
      },
    );
  }

  @override
  Widget buildOutputWidget(AssociatedDataItemGenerated state) {
    final columns = state.columnDefinitions; //state.table.columns;
    final rows = state.table.rows;

    if (rows.length > 0) {
      return Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                  Expanded(
                    child: Text(
                      '#',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ] +
                columns.map((colDef) {
                  return Expanded(
                    child: Text(
                      colDef.name,
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
                    value: 'Select Record ${index + 1}',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                            Expanded(
                              child: Text((index + 1).toString()),
                            )
                          ] +
                          columns.map((colDef) {
                            final value = row[colDef.name];
                            String text = (value ?? '').toString();

                            if (colDef is NumericColumn && value is num) {
                              text = value.truncateToDouble() == value
                                  ? value.toStringAsFixed(0)
                                  : value.toString();
                            } else if (colDef is DateTimeColumn) {
                              final format = DateFormat.yMd('en_US');

                              text = format.format(value);
                            }

                            return Expanded(
                              child: Text(text),
                            );
                          }).toList(),
                    ),
                    onTap: () => _onRowTap(
                          context,
                          state.columnDefinitions,
                          state.table,
                          row,
                          index,
                        ),
                  ),
                  onTap: () => _onRowTap(
                        context,
                        state.columnDefinitions,
                        state.table,
                        row,
                        index,
                      ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const Text('There is no data yet, please add something');
    }
  }

  @override
  bool returnToMainScreen() => false;

  void _onNewRecord(BuildContext context, List<ColumnDef> columnDefinitions,
      AssociatedDataTable table) async {
    final newRow = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RowEditorScreen(
              columnDefinitions: columnDefinitions,
              row: Map<String, dynamic>.fromIterable(columnDefinitions,
                  key: (colDef) => colDef.name,
                  value: (colDef) => colDef.defaultValue),
            ),
      ),
    );

    if (newRow != null) {
      viewObjectBloc.dispatch(AddRow(table: table, row: newRow));
    }
  }

  void _onRowTap(BuildContext context, List<ColumnDef> columnDefinitions,
      AssociatedDataTable table, Map<String, dynamic> row, int index) async {
    final dialogResult =
        await _showRecordDialog(context, columnDefinitions, row, index);

    switch (dialogResult) {
      case RecordAction.EDIT:
        {
          final modifiedRow = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RowEditorScreen(
                    columnDefinitions: columnDefinitions,
                    row: Map<String, dynamic>.from(row),
                  ),
            ),
          );

          if (modifiedRow != null) {
            viewObjectBloc.dispatch(
                UpdateRow(table: table, row: modifiedRow, index: index));
          }

          break;
        }
      case RecordAction.REMOVE:
        {
          viewObjectBloc.dispatch(RemoveRow(table: table, index: index));

          break;
        }
      default:
    }
  }

  Future<RecordAction> _showRecordDialog(
      BuildContext context,
      List<ColumnDef> columnDefinitions,
      Map<String, dynamic> row,
      int index) async {
    return await showDialog<RecordAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Record ${index + 1}'),
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
