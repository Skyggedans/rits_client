import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../models/projects/projects.dart';
import '../settings.dart' as settings;
import '../utils/utils.dart';
import 'luis.dart';

class LuisBloc extends Bloc<LuisEvent, LuisState> {
  final RestClient restClient;
  final LuisClient luisClient;

  LuisBloc({@required this.restClient, @required this.luisClient});

  @override
  get initialState => LuisUninitialized();

  @override
  Stream<LuisEvent> transform(Stream<LuisEvent> events) {
    return (events as Observable<LuisEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<LuisState> mapEventToState(LuisEvent event) async* {
    if (event is LoadLuisProject) {
      try {
        final luisProjectId = await _getLuisProjectId(event.project);

        yield UtteranceInput(luisProjectId: luisProjectId);
      } on ApiError {
        yield LuisError();
      }
    } else if (event is ExecuteUtterance) {
      yield UtteranceExecution();

      try {
        final response = await _executeUtterance(
          event.utteranceText,
          event.luisProjectId,
          event.userToken,
        );

        if (response.containsKey('url')) {
          yield UtteranceExecutedWithUrl(url: response['url']);
        } else {
          yield UtteranceInput(luisProjectId: event.luisProjectId);
        }
      } on ApiError {
        yield LuisError();
      }
    }
  }

  Future<String> _getLuisProjectId(Project project) async {
    final url = '${settings.luisConfig["host"]}/luis/api/v2.0/apps';
    final response = await luisClient.get(url);
    final List projects = json.decode(response.body);

    final luisProject = projects.firstWhere((p) => p['name'] == project.name,
        orElse: () => null);

    return luisProject != null ? luisProject['id'] : null;
  }

  Future<Map<String, dynamic>> _executeUtterance(
      String utteranceText, String luisProjectId, String userToken) async {
    final url = '${settings.luisUrl}/ExecuteUtterance/$userToken';

    final requestBody = {
      'Utterance': utteranceText,
      'ProjectLuisID': luisProjectId
    };

    final response = await restClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    return json.decode(response.body);
  }
}
