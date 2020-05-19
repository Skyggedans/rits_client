import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/kpi/kpi.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/auth/auth_repository.dart';

import 'luis.dart';

class LuisScreen extends StatefulWidget {
  @override
  State createState() => _LuisScreenState();
}

class _LuisScreenState extends State<LuisScreen> {
  LuisBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = LuisBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(LoadLuisProject());
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LUIS'),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: _bloc,
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
                  _bloc.add(ExecuteUtterance(
                    utteranceText: text,
                    luisAppId: state.luisAppId,
                  ));
                },
              ),
            );
          } else if (state is UtteranceExecutedWithUrl) {
            if (state.url.startsWith('http')) {
              final uri = Uri.parse(state.url);
              final authRepository = Provider.of<AuthRepository>(context);

              return InAppWebView(
                initialUrl: uri.toString(),
                initialHeaders: {
                  'Authorization': 'Bearer ${authRepository.accessToken}',
                },
                initialOptions: null,
              );
            } else {
              return Text(state.url);
            }
          } else if (state is UtteranceExecutedWithKpis) {
            if (state.kpis.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: state.kpis.length,
                itemBuilder: (context, index) {
                  return buildKpiCard(state.kpis[index]);
                },
              );
            } else {
              return const Text('No data');
            }
          }

          return const Text('Failed to start LUIS');
        },
      )),
    );
  }
}
