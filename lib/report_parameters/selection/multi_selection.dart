import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/rest_client.dart';
import '../../models/report_parameters/report_parameters.dart';
import 'selection.dart';

class MultiSelection extends StatefulWidget {
  final ReportParameter param;
  final String userToken;

  MultiSelection({Key key, @required this.param, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _MultiSelectionState();
}

class _MultiSelectionState extends State<MultiSelection> {
  final MultiSelectionBloc _selectionBloc =
      MultiSelectionBloc(restClient: RestClient());

  ReportParameter get _param => widget.param;

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _selectionBloc.dispatch(FetchSelectionOptions(
      param: _param,
      userToken: _userToken,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _selectionBloc,
      builder: (BuildContext context, SelectionState state) {
        Widget bodyChild;

        if (state is SelectionOptionsUninitialized) {
          bodyChild = CircularProgressIndicator();
        } else if (state is SelectionOptionsLoaded) {
          bodyChild = BlocProvider(
            bloc: _selectionBloc,
            child: _SelectionOptions(),
          );
        } else if (state is SelectionOptionsError) {
          bodyChild = Text('Failed to fetch selection options');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_param.title),
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
                  if (state is SelectionOptionsLoaded) {
                    Navigator.pop(context, state.options);
                  }
                },
              )
            ],
          ),
          body: Center(child: bodyChild),
        );
      },
    );
  }
}

class _SelectionOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _selectionBloc = BlocProvider.of<MultiSelectionBloc>(context);

    return BlocBuilder(
      bloc: _selectionBloc,
      builder: (BuildContext context, SelectionState state) {
        if (state is SelectionOptionsLoaded<Filter>) {
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: state.options.length,
            itemBuilder: (context, index) {
              Filter option = state.options[index];

              return CheckboxListTile(
                title: Text(option.title),
                value: option.state,
                onChanged: (bool value) {
                  _selectionBloc.dispatch(
                      UpdateSelection(option: option.copyWith(state: value)));
                },
              );
            },
          );
        }
      },
    );
  }
}
