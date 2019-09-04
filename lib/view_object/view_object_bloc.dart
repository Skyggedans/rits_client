import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'package:rits_client/models/app_config.dart';
import 'package:rits_client/models/projects/project_context.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'view_object.dart';

abstract class ViewObjectBloc extends Bloc<ViewObjectEvent, ViewObjectState> {
  final AppConfig appConfig = GetIt.instance<AppConfig>();
  final RestClient restClient = GetIt.instance<RestClient>();
  final ProjectContext projectContext;

  ViewObjectBloc({@required this.projectContext})
      : assert(projectContext != null);

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
