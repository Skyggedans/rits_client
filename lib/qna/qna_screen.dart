import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/utils/rest_client.dart';

import 'qna.dart';

class QnaScreen extends StatefulWidget {
  QnaScreen({Key key}) : super(key: key);

  @override
  State createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  QnaBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = QnaBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(LoadQnaModules());
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
        title: const Text('Questions & Answers'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: BlocBuilder(
            cubit: _bloc,
            builder: (BuildContext context, QnaState state) {
              if (state is QnaLoading) {
                return CircularProgressIndicator();
              } else if (state is QnaModulesLoaded) {
                return Provider.value(
                  value: _bloc,
                  child: _QnaModuleButtons(),
                );
              }

              return const Text('Failed to load QnA modules');
            },
          ),
        ),
      ),
    );
  }
}

class _QnaModuleButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppContext, QnaBloc>(
      builder: (context, appContext, qnaBloc, _) => BlocBuilder(
        cubit: qnaBloc,
        builder: (BuildContext context, QnaState state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (state as QnaModulesLoaded).modules.map((moduleName) {
              return RaisedButton(
                  child: Text(moduleName),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QnaModuleScreen(qnaName: moduleName),
                      ),
                    );
                  });
            }).toList(),
          );
        },
      ),
    );
  }
}
