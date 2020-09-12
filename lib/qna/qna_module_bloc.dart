import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/qna/qna.dart';
import 'package:rits_client/qna/qna.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

class QnaModuleBloc extends Bloc<QnaEvent, QnaState> {
  final RestClient restClient;
  final AppContext appContext;

  QnaModuleBloc({
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
    if (event is BeginQnaSession) {
      yield QnaLoading();

      try {
        await _beginSession(event.name);

        add(GetQnaPrompt(event.name, initial: true));
      } on ApiError {
        yield QnaError();
      }
    } else if (event is GetQnaPrompt) {
      yield QnaLoading();

      try {
        final prompt = await _getPrompt(event.name);
        final status = await _pullStatus(event.name);

        switch (status.status) {
          case QnaResponseStatus.waiting_for_input:
            yield QnaPrompt(
              text: prompt,
              isFirst: event.initial,
              items: status.items,
            );

            break;
          case QnaResponseStatus.done:
            yield QnaComplete(text: prompt);

            break;
          default:
            yield QnaError();
        }
      } on ApiError {
        yield QnaError();
      }
    } else if (event is SendQnaResponse) {
      yield QnaLoading();

      try {
        await _sendResponse(event.name, event.response);

        add(GetQnaPrompt(event.name));
      } on ApiError {
        yield QnaError();
      }
    } else if (event is QnaBack) {
      yield QnaLoading();

      try {
        await _stepBack(event.name);

        add(GetQnaPrompt(event.name));
      } on ApiError {
        yield QnaError();
      }
    } else if (event is QnaRestart) {
      yield QnaLoading();

      try {
        await _restartSession(event.name);

        add(GetQnaPrompt(event.name, initial: true));
      } on ApiError {
        yield QnaError();
      }
    }
  }

  Future<void> _beginSession(String name) async {
    final hierarchy =
        appContext.hasSessionContext ? '/${appContext.hierarchyParam}' : '';
    final url =
        '${settings.qnaUrl}/BeginQnASession/${appContext.userToken}/${name}${hierarchy}';

    await restClient.get(url);
  }

  Future<void> _stepBack(String name, {String hierarchy}) async {
    final hierarchy =
        appContext.hasSessionContext ? '/${appContext.hierarchyParam}' : '';
    final url =
        '${settings.qnaUrl}/Back/${appContext.userToken}/${name}${hierarchy}';

    await restClient.get(url);
  }

  Future<void> _restartSession(String name, {String hierarchy}) async {
    final hierarchy =
        appContext.hasSessionContext ? '/${appContext.hierarchyParam}' : '';
    final url =
        '${settings.qnaUrl}/Restart/${appContext.userToken}/${name}${hierarchy}';

    await restClient.get(url);
  }

  Future<String> _getPrompt(String name) async {
    final url = '${settings.qnaUrl}/QnAPrompt/${appContext.userToken}/${name}';
    final response = await restClient.get(url);

    return json.decode(response.body) as String;
  }

  Future<QnaStatus> _pullStatus(String name) async {
    final url = '${settings.qnaUrl}/PullStatus/${appContext.userToken}/${name}';
    final response = await restClient.get(url);

    return QnaStatus.fromJson(
        json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> _sendResponse(String name, bool response,
      {String hierarchy}) async {
    final hierarchy =
        appContext.hasSessionContext ? '/${appContext.hierarchyParam}' : '';
    final url =
        '${settings.qnaUrl}/QnASendResponse/${appContext.userToken}/${name}/${response}${hierarchy}';

    await restClient.get(url);
  }
}
