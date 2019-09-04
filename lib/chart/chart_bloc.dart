import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/errors.dart';
import 'package:rits_client/view_object/view_object.dart';
import 'chart.dart';

class ChartBloc extends ViewObjectBloc {
  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        yield ChartPresentation(
          viewObject: event.viewObject,
          url:
              '${settings.webUrl}/Charts/BaseChart?skypeBotToken=${event.userToken}&chart=${Uri.encodeFull(event.viewObject.name)}',
        );
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }
}
