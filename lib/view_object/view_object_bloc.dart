import 'dart:async';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:rits_client/models/app_config.dart';
import 'package:rits_client/models/projects/project_context.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../utils/rest_client.dart';
import 'view_object.dart';

abstract class ViewObjectBloc extends Bloc<ViewObjectEvent, ViewObjectState> {
  final AppConfig appConfig;
  final ProjectContext projectContext;
  final RestClient restClient;

  ViewObjectBloc({
    @required this.appConfig,
    @required this.projectContext,
    @required this.restClient,
  })  : assert(appConfig != null),
        assert(projectContext != null),
        assert(restClient != null);

  @override
  get initialState => ViewObjectIdle();

  @override
  Stream<ViewObjectEvent> transform(Stream<ViewObjectEvent> events) {
    return (events as Observable<ViewObjectEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is ReturnToViewObjectMainScreen) {
      yield ViewObjectIdle();
    }
  }
}
