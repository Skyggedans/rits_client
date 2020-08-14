import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_object.dart';
import 'package:rits_client/utils/rest_client.dart';

import 'qna.dart';

class QnaModuleScreen extends StatefulWidget {
  final String qnaName;

  QnaModuleScreen({Key key, @required this.qnaName})
      : assert(qnaName != null),
        super(key: key);

  @override
  State createState() => _QnaModuleScreenState();
}

class _QnaModuleScreenState extends State<QnaModuleScreen> {
  QnaModuleBloc _bloc;

  String get _qnaName => widget.qnaName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = QnaModuleBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(BeginQnaSession(_qnaName));
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
        title: Text(_qnaName),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: BlocBuilder(
              cubit: _bloc,
              builder: (BuildContext context, QnaState state) {
                if (state is QnaLoading) {
                  return CircularProgressIndicator();
                } else if (state is QnaPrompt) {
                  final inputs = Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Select:'),
                          RaisedButton(
                            child: const Text('Yes'),
                            onPressed: () =>
                                _bloc.add(SendQnaResponse(_qnaName, true)),
                          ),
                          RaisedButton(
                            child: const Text('No'),
                            onPressed: () =>
                                _bloc.add(SendQnaResponse(_qnaName, false)),
                          ),
                          Visibility(
                            visible: !state.isFirst,
                            child: RaisedButton(
                              child: const Text('Step Back'),
                              onPressed: () => _bloc.add(QnaBack(_qnaName)),
                            ),
                          ),
                          Visibility(
                            visible: !state.isFirst,
                            child: RaisedButton(
                              child: const Text('Restart'),
                              onPressed: () => _bloc.add(QnaRestart(_qnaName)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  final outputs = Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Provider.value(
                          value: _bloc,
                          child: _QnaItemButtons(),
                        ),
                      ),
                    ),
                  );

                  return Column(children: [
                    Text(
                      state.text,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > constraints.maxHeight) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [inputs, outputs],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [inputs, outputs],
                        );
                      }
                    }))
                  ]);
                } else if (state is QnaComplete) {
                  return const Text('QnA session is done');
                } else {
                  return const Text('');
                }
              }),
        ),
      ),
    );
  }
}

class _QnaItemButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppContext, QnaModuleBloc>(
      builder: (context, appContext, qnaBloc, _) => BlocBuilder(
        cubit: qnaBloc,
        builder: (BuildContext context, QnaState state) {
          return Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 5,
            children: (state as QnaPrompt).items.map((item) {
              return RaisedButton(
                child: Text(item.name),
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    '/${item.type}',
                    arguments: {
                      'viewObject': ViewObject(
                        name: item.name,
                        title: item.name,
                        itemType: item.type,
                      )
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
