import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/kpi/kpi.dart';
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
        } else if (response.containsKey('ViewType') &&
            response['ViewType']?.toString()?.toLowerCase() == 'kpis' &&
            response.containsKey('ViewItemDetails')) {
          final kpis = List<Map<String, dynamic>>.from(
                  response['ViewItemDetails'] as List)
              .map((kpiJson) {
            return Kpi.fromJson(kpiJson);
          }).toList();

          yield UtteranceExecutedWithKpis(kpis: kpis);
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
    final luisKey = await _getLuisKey();
    final url =
        '${settings.luisConfig["host"]}/${settings.luisConfig["path"]}/apps';

    final response = await restClient.get(url, headers: {
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key': luisKey
    });

    final projects =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    final luisProject = projects.firstWhere((p) => p['name'] == project.name,
        orElse: () => null);

    return luisProject != null ? luisProject['id'] as String : null;
  }

  Future<String> _getLuisKey() async {
    final url = '${settings.luisUrl}/GetLuisKey';
    final response = await restClient.get(url);
    final body = Map<String, dynamic>.from(json.decode(response.body) as Map);

    return body['key'] as String;
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
