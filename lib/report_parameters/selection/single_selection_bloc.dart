import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../../settings.dart' as settings;
import '../../utils/rest_client.dart';
import '../../models/report_parameters/report_parameters.dart';
import 'selection.dart';

class SingleSelectionBloc extends Bloc<SelectionEvent, SelectionState> {
  final RestClient restClient;

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

        yield SelectionOptionsLoaded(options: options);
      } catch (_) {
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
      ReportParameter param, String userToken) async {
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
