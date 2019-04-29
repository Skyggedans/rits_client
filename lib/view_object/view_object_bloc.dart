import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../utils/rest_client.dart';
import 'view_object.dart';

abstract class ViewObjectBloc extends Bloc<ViewObjectEvent, ViewObjectState> {
  final RestClient restClient;

  ViewObjectBloc({@required this.restClient});

  @override
  get initialState => ViewObjectIdle();

  @override
  Stream<ViewObjectEvent> transform(Stream<ViewObjectEvent> events) {
    return (events as Observable<ViewObjectEvent>)
        .debounce(Duration(milliseconds: 500));
  }
}
