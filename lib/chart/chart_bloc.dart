import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../view_object/view_object.dart';
import 'chart.dart';

class ChartBloc extends ViewObjectBloc {
  ChartBloc() : super(restClient: RestClient());

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        yield ChartPresentation(
          viewObject: event.viewObject,
          url:
              //'${settings.backendUrl}/showchart/${event.userToken}/${Uri.encodeFull(event.viewObject.name)}',
              '${settings.chartUrl}/Charts/BaseChart?skypeBotToken=${event.userToken}&chart=${Uri.encodeFull(event.viewObject.name)}',
          userToken: event.userToken,
        );
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }
}
