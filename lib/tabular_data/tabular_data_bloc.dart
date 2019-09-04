import 'dart:convert';

import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/utils.dart';
import 'package:rits_client/view_object/view_object.dart';
import 'tabular_data.dart';

class TabularDataBloc extends ViewObjectBloc {
  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final data = await _getData(
          event.viewObject,
          projectContext.userToken,
        );

        yield TabularDataGenerated(data: data);
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<List<dynamic>> _getData(
      ViewObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/fetch/$userToken/3/${Uri.encodeFull(viewObject.name)}';
    final response = await restClient.get(url);

    return json.decode(response.body)[0];
  }
}
