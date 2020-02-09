import 'dart:async';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:rits_client/models/view_objects/view_object.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../utils/rest_client.dart';
import '../settings.dart' as settings;
import 'view_object.dart';

abstract class ViewObjectBloc extends Bloc<ViewObjectEvent, ViewObjectState> {
  final RestClient restClient;

  ViewObjectBloc({@required this.restClient}) : assert(restClient != null);

  @override
  get initialState => ViewObjectUninitialized();

  @override
  Stream<ViewObjectState> transformStates(Stream<ViewObjectState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GetFavoriteId) {
      final favoriteId =
          await _getFavoriteId(event.userToken, event.viewObject);

      yield ViewObjectIdle(favoriteId: favoriteId);
    } else if (event is AddFavorite) {
      yield ViewObjectUninitialized();

      await _addFavorite(event.userToken, event.viewObject);

      final favoriteId =
          await _getFavoriteId(event.userToken, event.viewObject);

      yield ViewObjectIdle(favoriteId: favoriteId);
    } else if (event is RemoveFavorite) {
      yield ViewObjectUninitialized();

      await _removeFavorite(event.userToken, event.favoriteId);

      yield ViewObjectIdle(favoriteId: -1);
    } else if (event is ReturnToViewObjectMainScreen) {
      final favoriteId =
          await _getFavoriteId(event.userToken, event.viewObject);

      yield ViewObjectIdle(favoriteId: favoriteId);
    }
  }

  Future<int> _getFavoriteId(String userToken, ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/FavoriteReportItemExist/$userToken/${Uri.encodeFull(viewObject.name)}/${Uri.encodeFull(viewObject.itemType)}/0'; //${Uri.encodeFull(viewObject.hierarchyLevel)}';
    final response = await restClient.get(url);

    return int.tryParse(response.body ?? '');
  }

  Future<bool> _addFavorite(String userToken, ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/AddFavoriteReportItem/$userToken/${Uri.encodeFull(viewObject.name)}/${Uri.encodeFull(viewObject.itemType)}/${Uri.encodeFull(viewObject.hierarchyLevel)}';
    final response = await restClient.get(url);

    return (response.body ?? '') == 'true';
  }

  Future<bool> _removeFavorite(String userToken, int favoriteId) async {
    final url =
        '${settings.backendUrl}/RemoveFavoriteReportItem/$userToken/$favoriteId';
    final response = await restClient.get(url);

    return (response.body ?? '') == 'true';
  }
}
