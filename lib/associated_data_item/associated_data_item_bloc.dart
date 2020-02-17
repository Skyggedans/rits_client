import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/associated_data/associated_data.dart';
import 'package:rits_client/models/associated_data/business_object.dart';
import 'package:rits_client/models/associated_data/table.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rits_client/view_object/view_object.dart';

import 'associated_data_item.dart';

class AssociatedDataItemBloc extends ViewObjectBloc {
  AssociatedDataItemBloc({
    @required RestClient restClient,
    @required AppContext appContext,
  }) : super(restClient: restClient, appContext: appContext);

  @override
  get initialState => ViewObjectGeneration();

  @override
  Stream<ViewObjectState> mapEventToState(ViewObjectEvent event) async* {
    final prevState = state;

    if (event is GenerateViewObject<BusinessObject>) {
      yield ViewObjectGeneration();

      try {
        final columns = await _getColumnDefinitions(event.viewObject);
        final data = await _getData(event.viewObject);

        if (data == null) {
          yield NoActiveContainerError();
          return;
        }

        yield AssociatedDataItemGenerated(
          columnDefinitions: columns,
          table: data,
          viewObject: event.viewObject,
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
        await _saveRows(event.table, event.viewObject);
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

  Future<AssociatedDataTable> _getData(BusinessObject viewObject) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataContainer/${appContext.userToken}/${viewObject.id}';

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
      BusinessObject viewObject) async {
    final url =
        '${settings.backendUrl}/GetAssociatedDataValidation/${appContext.userToken}/${viewObject.name}';

    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((colDefJson) {
      return ColumnDef.fromJson(colDefJson);
    }).toList();
  }

  Future<void> _saveRows(
      AssociatedDataTable table, BusinessObject viewObject) async {
    final url =
        '${settings.backendUrl}/UpdateBusObjectAssociatedData/${appContext.userToken}/${table.container.id}';

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
