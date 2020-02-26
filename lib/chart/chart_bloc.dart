import 'package:flutter/foundation.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'chart.dart';

class ChartBloc extends ViewObjectBloc {
  ChartBloc({
    @required RestClient restClient,
    @required AppContext appContext,
  }) : super(restClient: restClient, appContext: appContext);

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        yield ChartPresentation(
          viewObject: event.viewObject,
          url:
              '${settings.chartUrl}/Charts/BaseChart?skypeBotToken=${appContext.userToken}&chart=${Uri.encodeFull(event.viewObject.name)}',
        );
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }
}
