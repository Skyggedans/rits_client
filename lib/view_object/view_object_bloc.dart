import 'dart:async';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../utils/rest_client.dart';
import 'view_object.dart';

abstract class ViewObjectBloc extends Bloc<ViewObjectEvent, ViewObjectState> {
  final RestClient restClient;

  ViewObjectBloc({@required this.restClient}) : assert(restClient != null);

  @override
  get initialState => ViewObjectIdle();

  @override
  Stream<ViewObjectState> transformStates(Stream<ViewObjectState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is ReturnToViewObjectMainScreen) {
      yield ViewObjectIdle();
    }
  }
}
