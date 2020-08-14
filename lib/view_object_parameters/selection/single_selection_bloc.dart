import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'selection.dart';

class SingleSelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final RestClient restClient;
  final AppContext appContext;

  SingleSelectionBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super(SelectionOptionsUninitialized());

  @override
  Stream<SelectionState> transformStates(Stream<SelectionState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<SelectionState> mapEventToState(SelectionEvent event) async* {
    if (event is FetchSelectionOptions) {
      try {
        final options = await _fetchParamOptions(event.param);

        yield SelectionOptionsLoaded(
          options: options,
          selection: event.param.value,
        );
      } on ApiError {
        yield SelectionOptionsError();
      }
    } else if (event is UpdateSelection) {
      yield SelectionOptionsLoaded(
        options: (state as SelectionOptionsLoaded<dynamic>).options,
        selection: event.option,
      );
    }
  }

  Future<List<dynamic>> _fetchParamOptions(ViewObjectParameter param) async {
    final url =
        '${settings.backendUrl}/GetPickListItems/${appContext.userToken}/${Uri.encodeFull(param.name)}';

    final response = await restClient.get(url);

    final body = json.decode(response.body) as List;

    if (param.dataType == 'number') {
      return body.map((option) {
        return double.tryParse(option as String);
      }).toList();
    } else {
      return body.map((option) {
        return option;
      }).toList();
    }
  }
}
