import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/qna/qna.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

class QnaBloc extends Bloc<QnaEvent, QnaState> {
  final RestClient restClient;
  final AppContext appContext;

  QnaBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super(QnaLoading());

  @override
  Stream<QnaState> transformStates(Stream<QnaState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<QnaState> mapEventToState(QnaEvent event) async* {
    if (event is LoadQnaModules) {
      try {
        final modules = await _loadModules();

        yield QnaModulesLoaded(modules: modules);
      } on ApiError {
        yield QnaError();
      }
    }
  }

  Future<List<String>> _loadModules() async {
    final url = '${settings.qnaUrl}/Get/${appContext.userToken}';
    final response = await restClient.get(url);

    return List<String>.from(json.decode(response.body) as List);
  }
}
