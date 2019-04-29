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

        yield SelectionOptionsLoaded(options: options);
      } catch (_) {
        yield SelectionOptionsError();
      }
    } else if (event is UpdateSelection<Filter>) {
      final List<Filter> updatedOptions =
          (currentState as SelectionOptionsLoaded<Filter>)
              .options
              .map((option) {
        return option.title == event.option.title ? event.option : option;
      }).toList();

      yield SelectionOptionsLoaded(options: updatedOptions);
    }
  }

  Future<List<Filter>> _fetchParamOptions(
      ViewObjectParameter param, String userToken) async {
    final url =
        '${settings.backendUrl}/GetCategoryFilterData/$userToken/${param.name}';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    return body.map((option) {
      return Filter.fromJson(option);
    }).toList();
  }
}
