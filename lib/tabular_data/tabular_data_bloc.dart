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
      } catch (_) {
        yield ViewObjectError();
      }
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
