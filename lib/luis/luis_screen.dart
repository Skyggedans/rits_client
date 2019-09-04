import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';

import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'luis.dart';

class LuisScreen extends StatefulWidget {
  @override
  State createState() => _LuisScreenState();
}

class _LuisScreenState extends State<LuisScreen> {
  final LuisBloc _luisBloc =
      LuisBloc(restClient: RitsClient(), luisClient: LuisClient());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_luisBloc.currentState == _luisBloc.initialState) {
      final projectContext = Provider.of<ProjectContext>(context);

      _luisBloc.dispatch(LoadLuisProject(
        projectContext.project,
        projectContext.userToken,
      ));
    }
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
          final projectContext = Provider.of<ProjectContext>(context);

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
                  _luisBloc.dispatch(ExecuteUtterance(
                    utteranceText: text,
                    luisProjectId: state.luisProjectId,
                    userToken: projectContext.userToken,
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
          } else if (state is LuisError) {
            return const Text('Failed to start LUIS');
          }
        },
      )),
    );
  }

  @override
  void dispose() {
    _luisBloc.dispose();
    super.dispose();
  }
}
