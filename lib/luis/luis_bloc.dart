import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../models/projects/projects.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'luis.dart';

class LuisBloc extends Bloc<LuisEvent, LuisState> {
  final RestClient restClient;
  final LuisClient luisClient;

  LuisBloc({@required this.restClient, @required this.luisClient});

  @override
  get initialState => LuisUninitialized();

  @override
  Stream<LuisState> transformStates(Stream<LuisState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<LuisState> mapEventToState(LuisEvent event) async* {
    if (event is LoadLuisProject) {
      try {
        final luisProjectId = await _getLuisProjectId(event.project);

        yield UtteranceInput(
            luisProjectId: luisProjectId, userToken: event.userToken);
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
          yield UtteranceExecutedWithUrl(url: response['url'] as String);
        } else {
          yield UtteranceInput(
              luisProjectId: event.luisProjectId, userToken: event.userToken);
        }
      } on ApiError {
        yield LuisError();
      }
    }
  }

  Future<String> _getLuisProjectId(Project project) async {
    final url = '${settings.luisConfig["host"]}/luis/api/v2.0/apps';
    final response = await luisClient.get(url) as Response;
    final projects =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    final luisProject = projects.firstWhere((p) => p['name'] == project.name,
        orElse: () => null);

    return luisProject != null ? luisProject['id'] as String : null;
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

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
