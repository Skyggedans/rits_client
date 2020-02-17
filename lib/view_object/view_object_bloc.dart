import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_object.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'view_object.dart';

abstract class ViewObjectBloc extends Bloc<ViewObjectEvent, ViewObjectState> {
  final RestClient restClient;
  final AppContext appContext;

  ViewObjectBloc({@required this.restClient, @required this.appContext})
      : assert(restClient != null),
        assert(appContext != null),
        super();

  @override
  get initialState => ViewObjectUninitialized();

  @override
  Stream<ViewObjectState> transformStates(Stream<ViewObjectState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GetFavoriteId) {
      final favoriteId = await _getFavoriteId(event.viewObject);

      yield ViewObjectIdle(favoriteId: favoriteId);
    } else if (event is AddFavorite) {
      yield ViewObjectUninitialized();

      await _addFavorite(event.viewObject);

      final favoriteId = await _getFavoriteId(event.viewObject);

      yield ViewObjectIdle(favoriteId: favoriteId);
    } else if (event is RemoveFavorite) {
      yield ViewObjectUninitialized();

      await _removeFavorite(event.favoriteId);

      yield ViewObjectIdle(favoriteId: -1);
    } else if (event is ReturnToViewObjectMainScreen) {
      final favoriteId = await _getFavoriteId(event.viewObject);

      yield ViewObjectIdle(favoriteId: favoriteId);
    }
  }

  Future<int> _getFavoriteId(ViewObject viewObject) async {
    if (viewObject.name == null || viewObject.itemType == null) {
      return -1;
    }

    final url =
        '${settings.backendUrl}/FavoriteReportItemExist/${appContext.userToken}/${Uri.encodeFull(viewObject.name)}/${Uri.encodeFull(viewObject.itemType)}/0';
    final response = await restClient.get(url);

    return int.tryParse(response.body ?? '');
  }

  Future<bool> _addFavorite(ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/AddFavoriteReportItem/${appContext.userToken}/${Uri.encodeFull(viewObject.name)}/${Uri.encodeFull(viewObject.itemType)}/0';
    final response = await restClient.get(url);

    return (response.body ?? '') == 'true';
  }

  Future<bool> _removeFavorite(int favoriteId) async {
    final url =
        '${settings.backendUrl}/RemoveFavoriteReportItem/${appContext.userToken}/$favoriteId';
    final response = await restClient.get(url);

    return (response.body ?? '') == 'true';
  }
}
