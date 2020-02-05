import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../models/projects/projects.dart';
import '../utils/rest_client.dart';
import 'luis.dart';

class LuisScreen extends StatefulWidget {
  final Project project;
  final String userToken;

  LuisScreen({Key key, @required this.project, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _LuisScreenState();
}

class _LuisScreenState extends State<LuisScreen> {
  final LuisBloc _luisBloc =
      LuisBloc(restClient: RestClient(), luisClient: LuisClient());

  Project get _project => widget.project;
  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _luisBloc.add(LoadLuisProject(_project, _userToken));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LUIS'),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: _luisBloc,
        builder: (BuildContext context, LuisState state) {
          if (state is LuisUninitialized || state is UtteranceExecution) {
            return CircularProgressIndicator();
          } else if (state is UtteranceInput) {
            return Center(
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Please enter the utterance',
                  helperText: '',
                  helperStyle: TextStyle(
                    fontSize: 1,
                    color: Color.fromARGB(0, 0, 0, 0),
                  ),
                ),
                onFieldSubmitted: (text) {
                  _luisBloc.add(ExecuteUtterance(
                    utteranceText: text,
                    luisProjectId: state.luisProjectId,
                    userToken: state.userToken,
                  ));
                },
              ),
            );
          } else if (state is UtteranceExecutedWithUrl) {
            if (state.url.startsWith('http')) {
              return WebviewScaffold(
                url: state.url,
              );
            } else {
              return new Center(
                child: Text(state.url),
              );
            }
          }

          return const Text('Failed to start LUIS');
        },
      )),
    );
  }
}
