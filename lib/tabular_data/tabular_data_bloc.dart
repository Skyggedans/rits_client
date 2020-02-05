import 'dart:convert';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';
import 'tabular_data.dart';

class TabularDataBloc extends ViewObjectBloc {
  TabularDataBloc() : super(restClient: RestClient());

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final data = await _getData(event.viewObject, event.userToken);

        yield TabularDataGenerated(data: data);
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<List<Map<String, dynamic>>> _getData(
      ViewObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/fetch/$userToken/3/${Uri.encodeFull(viewObject.name)}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body)[0] as List);

    return body;
  }
}
