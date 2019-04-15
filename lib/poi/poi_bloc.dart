import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'package:android_intent/android_intent.dart';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/projects/projects.dart';
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
      final dynamic result = await _channel.invokeMethod('scanBarCode');

      yield ItemScanned(itemInfo: result);
    }
  }
}
