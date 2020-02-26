import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'tabular_data.dart';

class TabularDataBloc extends ViewObjectBloc {
  TabularDataBloc({
    @required RestClient restClient,
    @required AppContext appContext,
  }) : super(restClient: restClient, appContext: appContext);

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final data = await _getData(event.viewObject);

        yield TabularDataGenerated(data: data);
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<List<Map<String, dynamic>>> _getData(ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/fetch/${appContext.userToken}/3/${Uri.encodeFull(viewObject.name)}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body)[0] as List);

    return body;
  }
}
