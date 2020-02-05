import 'dart:convert';

import 'package:intl/intl.dart';

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
    final prevState = state;

    if (event is GenerateViewObject<BusinessObject>) {
      yield ViewObjectGeneration();

      try {
        final columns =
            await _getColumnDefinitions(event.viewObject, event.userToken);
        final data = await _getData(event.viewObject, event.userToken);

        if (data == null) {
          yield NoActiveContainerError();
          return;
        }

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

  // Future<AssociatedDataContainer> _getActiveContainer(
  //     BusinessObject viewObject, String userToken) async {
  //   final url =
  //       '${settings.backendUrl}/GetAssociatedDataForItem/$userToken/${viewObject.id}';

  //   final response = await restClient.get(url);
  //   final body = json.decode(response.body);

  //   final List<AssociatedDataContainer> containers =
  //       body.map<AssociatedDataContainer>((item) {
  //     return AssociatedDataContainer.fromJson(item);
  //   }).toList();

  //   return containers.firstWhere(
  //       (AssociatedDataContainer container) => container.isActive,
  //       orElse: () => null);
  // }

  Future<AssociatedDataTable> _getData(
      BusinessObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataContainer/$userToken/${viewObject.id}';

    final response = await restClient.get(url);

    final body = json.decode(response.body, reviver: (key, value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? value;
      }

      return value;
    }) as Map<String, dynamic>;

    return AssociatedDataTable(
      container: AssociatedDataContainer.fromJson(body),
      columns: List<String>.from(body['columns'] as List),
      rows: List<Map<String, dynamic>>.from(body['data'] as List),
    );
  }

  Future<List<ColumnDef>> _getColumnDefinitions(
      BusinessObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataValidation/$userToken/${viewObject.name}';

    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((colDefJson) {
      return ColumnDef.fromJson(colDefJson);
    }).toList();
  }

  Future<void> _saveRows(AssociatedDataTable table, BusinessObject viewObject,
      String userToken) async {
    final url =
        '${settings.backendUrl}/UpdateBusObjectAssociatedData/$userToken/${table.container.id}';

    table.rows.forEach((row) {
      row['AssociatedDataHeaderID'] = table.container.id;
    });

    await restClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(table.rows, toEncodable: (object) {
        if (object is DateTime) {
          final format = DateFormat('MM/dd/yyyy hh:mm:ss a');

          return format.format(object);
        }

        return object.toString();
      }),
    );
  }
}
