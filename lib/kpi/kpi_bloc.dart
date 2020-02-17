import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/kpi/kpi.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'kpi.dart';

class KpiBloc extends ViewObjectBloc {
  KpiBloc({@required RestClient restClient, @required AppContext appContext})
      : super(restClient: restClient, appContext: appContext);

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final kpis = await _getKpis(event.viewObject);

        yield KpiGenerated(kpis: kpis);
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<List<Kpi>> _getKpis(ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/fetch/${appContext.userToken}/0/SystemKpi/${Uri.encodeFull(viewObject.name)}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((kpiJson) {
      return Kpi.fromJson(kpiJson);
    }).toList();
  }
}
