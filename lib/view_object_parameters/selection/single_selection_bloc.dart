import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/utils.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'selection.dart';

class SingleSelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final RitsClient restClient;

  SingleSelectionBloc({@required this.restClient});

  @override
  Stream<SelectionEvent> transform(Stream<SelectionEvent> events) {
    return (events as Observable<SelectionEvent>)
        .debounce(Duration(milliseconds: 500));
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
        options: (currentState as SelectionOptionsLoaded<dynamic>).options,
        selection: event.option,
      );
    }
  }

  Future<List<dynamic>> _fetchParamOptions(
      ViewObjectParameter param, String userToken) async {
    final url =
        '${settings.backendUrl}/GetPickListItems/$userToken/${Uri.encodeFull(param.name)}';

    final response = await restClient.get(url);

    final List body = json.decode(response.body);

    if (param.dataType == 'number') {
      return body.map((option) {
        return double.tryParse(option);
      }).toList();
    } else {
      return body.map((option) {
        return option;
      }).toList();
    }
  }
}
