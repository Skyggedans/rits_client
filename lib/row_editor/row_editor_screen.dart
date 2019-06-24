import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/associated_data/associated_data.dart';
import '../widgets/widgets.dart';

class RowEditorScreen extends StatefulWidget {
  final List<ColumnDef> columnDefinitions;
  final Map<String, dynamic> row;

  RowEditorScreen(
      {Key key, @required this.columnDefinitions, @required this.row})
      : assert(columnDefinitions != null),
        assert(row != null),
        super(key: key);

  @override
  State createState() => _RowEditorScreenState();
}

class _RowEditorScreenState extends State<RowEditorScreen> {
  Map<String, dynamic> _row;

  List<ColumnDef> get _columnDefinitions => widget.columnDefinitions;

  @override
  void initState() {
    _row = widget.row;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Row Editor'),
        actions: <Widget>[
          FlatButton(
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                Text(
                  'ACCEPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop(_row);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 10,
          children: _columnDefinitions.map((columnDef) {
            if (columnDef is NumericColumn) {
              return SizedBox(
                width: 250,
                child: TextFormField(
                  autovalidate: true,
                  initialValue: _row[columnDef.name].toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: columnDef.name,
                    helperText: columnDef.name,
                    helperStyle: TextStyle(
                      fontSize: 1,
                      color: Color.fromARGB(0, 0, 0, 0),
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    setState(() {
                      _row[columnDef.name] = num.tryParse(value) ?? 0;
                    });
                  },
                  validator: (value) {
                    final numValue = num.tryParse(value) ?? 0;

                    if (columnDef.min == 0 && columnDef.max == 0) {
                      return null;
                    }

                    if (numValue >= columnDef.min &&
                        numValue <= columnDef.max) {
                      return null;
                    } else {
                      return 'Value is outside the allowed range (${columnDef.min} - ${columnDef.max})';
                    }
                  },
                ),
              );
            } else if (columnDef is StringColumn) {
              getField() {
                if (columnDef?.options?.isNotEmpty ?? false) {
                  final dropDownValue =
                      (columnDef?.options.contains(_row[columnDef.name]) ??
                              false)
                          ? _row[columnDef.name]
                          : null;

                  return Semantics(
                    button: true,
                    excludeSemantics: true,
                    //explicitChildNodes: true,
                    focused: true,
                    //value: columnDef.name,
                    //hint: columnDef.name,
                    label: columnDef.name,
                    onTap: () {
                      //Finder.byType(MyChildWidget);
                      print('test');
                    },
                    child: DropdownButtonFormField<String>(
                      value: dropDownValue,
                      decoration: InputDecoration(
                        labelText: columnDef.name,
                        helperText: columnDef.name,
                        labelStyle: TextStyle(
                          fontSize: 12,
                        ),
                        helperStyle: TextStyle(
                          fontSize: 1,
                          color: Color.fromARGB(0, 0, 0, 0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _row[columnDef.name] = value;
                        });
                      },
                      items: columnDef.options
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                            width: 200,
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return TextFormField(
                    initialValue: _row[columnDef.name],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: columnDef.name,
                      helperText: columnDef.name,
                      helperStyle: TextStyle(
                        fontSize: 1,
                        color: Color.fromARGB(0, 0, 0, 0),
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      setState(() {
                        _row[columnDef.name] = value;
                      });
                    },
                  );
                }
              }

              return SizedBox(
                width: 250,
                child: getField(),
              );
            } else if (columnDef is DateTimeColumn) {
              return SizedBox(
                width: 250,
                child: DateTimePicker(
                  labelText: columnDef.name,
                  helperText: columnDef.name,
                  selectedDate: _row[columnDef.name],
                  selectDate: (value) {},
                ),
              );
            } else {
              Text(columnDef.name);
            }
          }).toList(),
        ),
      ),
    );
  }
}
