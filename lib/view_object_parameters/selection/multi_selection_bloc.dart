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

class MultiSelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final RestClient restClient;
  final AppContext appContext;

  MultiSelectionBloc({@required this.restClient, @required this.appContext})
      : assert(restClient != null),
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

  Future<List<Option>> _fetchParamOptions(ViewObjectParameter param) async {
    final url =
        '${settings.backendUrl}/GetCategoryFilterData/${appContext.userToken}/${param.name}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((optionJson) {
      return Option.fromJson(optionJson);
    }).toList();
  }
}
