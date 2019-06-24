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
  get initialState => ViewObjectGeneration();

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    final prevState = currentState;

    if (event is GenerateViewObject) {
      yield ViewObjectGeneration();

      try {
        final columns =
            await _getColumnDefinitions(event.viewObject, event.userToken);
        final data = await _getData(event.viewObject, event.userToken);

        yield AssociatedDataItemGenerated(
          columnDefinitions: columns,
          table: data,
          viewObject: event.viewObject,
          userToken: event.userToken,
        );
      } on ApiError {
        yield ViewObjectError();
      }
    } else if (event is AddRow) {
      yield ViewObjectGeneration();
      event.table.rows.add(event.row);

      if (prevState is AssociatedDataItemGenerated) {
        yield prevState.copyWith(table: prevState.table);
      } else {
        yield prevState;
      }
    } else if (event is UpdateRow) {
      yield ViewObjectGeneration();
      event.table.rows[event.index] = event.row;

      if (prevState is AssociatedDataItemGenerated) {
        yield prevState.copyWith(table: prevState.table);
      } else {
        yield prevState;
      }
    } else if (event is RemoveRow) {
      yield ViewObjectGeneration();
      event.table.rows.removeAt(event.index);

      if (prevState is AssociatedDataItemGenerated) {
        yield prevState.copyWith(table: prevState.table);
      } else {
        yield prevState;
      }
    } else if (event is SaveRows) {
      yield ViewObjectGeneration();

      try {
        await _saveRows(event.table, event.viewObject, event.userToken);
      } on ApiError {
        yield ViewObjectError();
      }

      if (prevState is AssociatedDataItemGenerated) {
        yield prevState.copyWith(table: prevState.table);
      } else {
        yield prevState;
      }
    } else {
      yield* super.mapEventToState(event);
    }
  }

  Future<AssociatedDataTable> _getData(
      BusinessObject viewObject, String userToken) async {
    // final url1 =
    //     '${settings.backendUrl}/GetAssociatedDataForItem/$userToken/${viewObject.id}';

    // final url2 =
    //     '${settings.backendUrl}/EditAssociatedData/$userToken/FormSource22/313';

    // final url3 =
    //     '${settings.backendUrl}/GetAssociatedDataValidation/$userToken/${viewObject.name}';

    final url =
        '${settings.backendUrl}/GetBusObjectAssociatedData/$userToken/1080';

    final response = await restClient.get(url);
    final body = json.decode(response.body);

    return AssociatedDataTable(
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

  Future<void> _saveRows(AssociatedDataTable table, BusinessObject viewObject,
      String userToken) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataValidation/$userToken/${viewObject.id}';

    await restClient.post(url, body: json.encode(table.rows));
  }
}
