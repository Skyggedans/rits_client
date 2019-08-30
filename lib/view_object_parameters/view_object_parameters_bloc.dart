import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../settings.dart' as settings;
import '../utils/utils.dart';
import '../models/view_objects/view_objects.dart';
import 'view_object_parameters.dart';

class ViewObjectParametersBloc
    extends Bloc<ViewObjectParametersEvent, ViewObjectParametersState> {
  final RestClient restClient;

  ViewObjectParametersBloc({@required this.restClient});

  @override
  Stream<ViewObjectParametersEvent> transform(
      Stream<ViewObjectParametersEvent> events) {
    return (events as Observable<ViewObjectParametersEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => ViewObjectParametersInProgress();

  @override
  Stream<ViewObjectParametersState> mapEventToState(
      ViewObjectParametersEvent event) async* {
    if (event is FetchViewObjectParameters) {
      yield ViewObjectParametersInProgress();

      try {
        final params =
            await _fetchViewObjectParams(event.viewObject, event.userToken);

        yield ViewObjectParametersLoaded(
          viewObject: event.viewObject,
          parameters: params,
        );
      } on ApiError {
        yield ViewObjectParametersError();
      }
    } else if (event is SaveViewObjectParameter) {
      yield ViewObjectParametersInProgress();

      try {
        await _saveViewObjectParam(
            event.viewObject, event.parameter, event.userToken);
        this.dispatch(FetchViewObjectParameters(
          viewObject: event.viewObject,
          userToken: event.userToken,
        ));
      } on ApiError {
        yield ViewObjectParametersError();
      }
    }
  }

  Future<List<ViewObjectParameter>> _fetchViewObjectParams(
      ViewObject viewObject, String userToken) async {
    final url =
        '${settings.backendUrl}/GetViewElementParameter/$userToken/${Uri.encodeFull(viewObject.name)}/${viewObject.itemType}';
    final response = await restClient.get(url);
    final List body = json.decode(response.body);

    List<ViewObjectParameter> allParams = body.map((param) {
      return ViewObjectParameter.fromJson(param);
    }).toList();

    allParams =
        allParams.fold(List<ViewObjectParameter>(), (params, nextParam) {
      if (!nextParam.name.endsWith('SelectedItem')) {
        final selectionValueParam = allParams.firstWhere(
            (param) => param.name == '${nextParam.name}SelectedItem',
            orElse: () => null);

        if (selectionValueParam != null) {
          nextParam = nextParam.copyWith(
            viewItem: selectionValueParam.viewItem,
            itemType: selectionValueParam.itemType,
            value: selectionValueParam.value,
          );
        }

        params.add(nextParam);
      }

      return params;
    });

    return allParams;
  }

  Future<void> _saveViewObjectParam(ViewObject viewObject,
      ViewObjectParameter param, String userToken) async {
    final paramJson = param.toJson();
    final name = Uri.encodeFull(paramJson['ParameterName']);

    if (param.value is List<Filter>) {
      final url =
          '${settings.backendUrl}/UpdateCategoryFilterData/$userToken/$name';

      await restClient.post(url,
          body: json.encode(paramJson['ParameterValue']));
    } else {
      final value = Uri.encodeFull(paramJson['ParameterValue']);
      final url =
          '${settings.backendUrl}/SetParameterValue/$userToken/$name/$value';

      await restClient.get(url);
    }
  }
}
