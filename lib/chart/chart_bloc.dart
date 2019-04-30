import 'dart:typed_data';

import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../models/view_objects/view_objects.dart';
import '../view_object/view_object.dart';

class ChartBloc extends ViewObjectBloc {
  ChartBloc() : super(restClient: RestClient());

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final bytes = await _getChartBytes(event.viewObject, event.userToken);

        yield ViewObjectGenerated(bytes: bytes);
      } catch (_) {
        yield ViewObjectError();
      }
    }
  }

  Future<Uint8List> _getChartBytes(
      ViewObject viewObject, String userToken) async {
    final url =
        '${settings.reportUrl}/Charts/BaseChart?skypeBotToken=$userToken&chart=${Uri.encodeFull(viewObject.name)}&export=jpg';
    // final url =
    //     '${settings.backendUrl}/showchart/$userToken/${Uri.encodeFull(viewObject.name)}/jpg';
    final response = await restClient.get(url);

    return response.bodyBytes;
  }
}
