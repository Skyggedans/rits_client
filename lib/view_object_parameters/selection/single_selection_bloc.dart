import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../../settings.dart' as settings;
import '../../utils/rest_client.dart';
import '../../models/view_objects/view_objects.dart';
import 'selection.dart';

class SingleSelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final RestClient restClient;

  SingleSelectionBloc({@required this.restClient});

  @override
  Stream<SelectionState> transformStates(Stream<SelectionState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  get initialState => SelectionOptionsUninitialized();

  @override
  Stream<SelectionState> mapEventToState(SelectionEvent event) async* {
    if (event is FetchSelectionOptions) {
      try {
        final options = await _fetchParamOptions(event.param, event.userToken);

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

  Future<List<dynamic>> _fetchParamOptions(
      ViewObjectParameter param, String userToken) async {
    final url =
        '${settings.backendUrl}/GetPickListItems/$userToken/${Uri.encodeFull(param.name)}';

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
