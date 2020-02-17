import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/utils/rest_client.dart';

import 'selection.dart';

class SingleSelection extends StatefulWidget {
  final ViewObjectParameter param;

  SingleSelection({Key key, @required this.param})
      : assert(param != null),
        super(key: key);

  @override
  State createState() => _SingleSelectionState();
}

class _SingleSelectionState extends State<SingleSelection> {
  SingleSelectionBloc _bloc;

  ViewObjectParameter get _param => widget.param;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = SingleSelectionBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(FetchSelectionOptions(param: _param));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, SelectionState state) {
        Widget bodyChild;

        if (state is SelectionOptionsUninitialized) {
          bodyChild = CircularProgressIndicator();
        } else if (state is SelectionOptionsLoaded) {
          bodyChild = Provider<SingleSelectionBloc>.value(
            value: _bloc,
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
    final _bloc = Provider.of<SingleSelectionBloc>(context);

    return BlocBuilder(
      bloc: _bloc,
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
                  _bloc.add(UpdateSelection(option: value));
                },
              );
            },
          );
        }

        return null;
      },
    );
  }
}
