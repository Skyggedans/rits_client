import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../../settings.dart' as settings;
import '../../utils/rest_client.dart';
import '../../models/view_objects/view_objects.dart';
import 'selection.dart';

class MultiSelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final RestClient restClient;

  MultiSelectionBloc({@required this.restClient});

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

        yield SelectionOptionsLoaded(options: options);
      } on ApiError {
        yield SelectionOptionsError();
      }
    } else if (event is UpdateSelection<Option>) {
      final List<Option> updatedOptions =
          (state as SelectionOptionsLoaded<Option>).options.map((option) {
        return option.title == event.option.title ? event.option : option;
      }).toList();

      yield SelectionOptionsLoaded(options: updatedOptions);
    }
  }

  Future<List<Option>> _fetchParamOptions(
      ViewObjectParameter param, String userToken) async {
    final url =
        '${settings.backendUrl}/GetCategoryFilterData/$userToken/${param.name}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((optionJson) {
      return Option.fromJson(optionJson);
    }).toList();
  }
}
