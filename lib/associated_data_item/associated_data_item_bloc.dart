import 'dart:convert';

import '../models/associated_data/associated_data.dart';
import '../models/associated_data/business_object.dart';
import '../models/associated_data/table.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import '../view_object/view_object.dart';
import 'associated_data_item.dart';

class AssociatedDataItemBloc extends ViewObjectBloc {
  AssociatedDataItemBloc() : super(restClient: RestClient());

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final columns =
            await _getColumnDefinitions(event.viewObject, event.userToken);
        final data = await _getData(event.viewObject, event.userToken);

        yield AssociatedDataItemGenerated(columns: columns, table: data);
      } on ApiError {
        yield ViewObjectError();
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<Table> _getData(BusinessObject viewObject, String userToken) async {
    final url1 =
        '${settings.backendUrl}/GetAssociatedDataForItem/$userToken/${viewObject.id}';

    // final url2 =
    //     '${settings.backendUrl}/EditAssociatedData/$userToken/FormSource22/313';

    // final url3 =
    //     '${settings.backendUrl}/GetAssociatedDataValidation/$userToken/${viewObject.name}';

    // final url =
    //     '${settings.backendUrl}/GetBusObjectAssociatedData/$userToken/1080';

    final response = await restClient.get(url1);
    final body = json.decode(response.body);

    return Table(
        columns: body['columns'].cast<String>(),
        rows: body['data'].cast<Map<String, dynamic>>());
  }

  Future<List<ColumnDef>> _getColumnDefinitions(
      BusinessObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataValidation/$userToken/${viewObject.name}';

    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((param) {
      return ColumnDef.fromJson(param);
    }).toList();
  }
}
