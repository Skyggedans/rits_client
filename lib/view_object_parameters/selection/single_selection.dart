import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/rest_client.dart';
import '../../models/view_objects/view_objects.dart';
import 'selection.dart';

class SingleSelection extends StatefulWidget {
  final ViewObjectParameter param;
  final String userToken;

  SingleSelection({Key key, @required this.param, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _SingleSelectionState();
}

class _SingleSelectionState extends State<SingleSelection> {
  final SingleSelectionBloc _selectionBloc =
      SingleSelectionBloc(restClient: RestClient());

  ViewObjectParameter get _param => widget.param;

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _selectionBloc.add(FetchSelectionOptions(
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
            create: (context) => _selectionBloc,
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
                    Navigator.pop(context, state.selection);
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
    // ignore: close_sinks
    final _selectionBloc = BlocProvider.of<SingleSelectionBloc>(context);

    return BlocBuilder(
      bloc: _selectionBloc,
      builder: (BuildContext context, SelectionState state) {
        if (state is SelectionOptionsLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: state.options.length,
            itemBuilder: (context, index) {
              final option = state.options[index];

              return RadioListTile(
                title: Text(option.toString()),
                value: option,
                groupValue: state.selection,
                onChanged: (value) {
                  _selectionBloc.add(UpdateSelection(option: value));
                },
              );
            },
          );
        }
      },
    );
  }
}
