import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'poi.dart';

class PoiBloc extends Bloc<PoiEvent, PoiState> {
  final RestClient restClient;
  static const MethodChannel _channel = MethodChannel('com.rockwellits.client');

  PoiBloc({@required this.restClient});

  @override
  get initialState => PoiUninitialized();

  @override
  Stream<PoiEvent> transform(Stream<PoiEvent> events) {
    return (events as Observable<PoiEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<PoiState> mapEventToState(PoiEvent event) async* {
    if (event is ScanItem) {
      final String result = await _channel.invokeMethod('scanBarCode');

      try {
        dynamic decodedResult = json.decode(result);
        final levelName = await _setContextFromBarCode(
            decodedResult['ritsData']['itemId'], event.userToken);

        if (levelName != null) {
          yield ItemScanned(
            itemInfo: decodedResult['ritsData']['itemId'],
            levelName: levelName,
            userToken: event.userToken,
          );
        } else {
          yield PoiError(itemInfo: 'Unable to set context');
        }
      } catch (_) {
        yield PoiError(itemInfo: 'Unrecognized content: $result');
      }
    }
  }

  Future<String> _setContextFromBarCode(
      String contextId, String userToken) async {
    final url =
        '${settings.backendUrl}/SetContextFromBarCode/$userToken/${Uri.encodeFull(contextId)}';
    final response = await restClient.get(url);

    return json.decode(response.body);
  }
}
