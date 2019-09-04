import 'dart:convert';

import 'package:rits_client/models/kpi/kpi.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/errors.dart';
import 'package:rits_client/view_object/view_object.dart';
import 'kpi.dart';

class KpiBloc extends ViewObjectBloc {
  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final kpis = await _getKpis(event.viewObject, event.userToken);

        yield KpiGenerated(kpis: kpis);
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<List<Kpi>> _getKpis(ViewObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/fetch/$userToken/0/SystemKpi/${Uri.encodeFull(viewObject.name)}';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((kpi) {
      return Kpi.fromJson(kpi);
    }).toList();
  }
}
