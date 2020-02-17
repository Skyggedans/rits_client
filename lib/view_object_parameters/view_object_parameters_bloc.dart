import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'view_object_parameters.dart';

class ViewObjectParametersBloc
    extends Bloc<ViewObjectParametersEvent, ViewObjectParametersState> {
  final RestClient restClient;
  final AppContext appContext;

  ViewObjectParametersBloc({
    @required this.restClient,
    @required this.appContext,
  })  : assert(restClient != null),
        assert(appContext != null),
        super();

  @override
  Stream<ViewObjectParametersState> transformStates(
      Stream<ViewObjectParametersState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  get initialState => ViewObjectParametersInProgress();

  @override
  Stream<ViewObjectParametersState> mapEventToState(
      ViewObjectParametersEvent event) async* {
    if (event is FetchViewObjectParameters) {
      yield ViewObjectParametersInProgress();

      try {
        final params = await _fetchViewObjectParams(event.viewObject);

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
        await _saveViewObjectParam(event.viewObject, event.parameter);

        this.add(FetchViewObjectParameters(viewObject: event.viewObject));
      } on ApiError {
        yield ViewObjectParametersError();
      }
    }
  }

  Future<List<ViewObjectParameter>> _fetchViewObjectParams(
      ViewObject viewObject) async {
    final url =
        '${settings.backendUrl}/GetViewElementParameter/${appContext.userToken}/${Uri.encodeFull(viewObject.name)}/${viewObject.itemType}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    var allParams = body.map((param) {
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

  Future<void> _saveViewObjectParam(
    ViewObject viewObject,
    ViewObjectParameter param,
  ) async {
    final paramJson = param.toJson();
    final name = Uri.encodeFull(paramJson['ParameterName'] as String);

    if (param.value is List<Option>) {
      final url =
          '${settings.backendUrl}/UpdateCategoryFilterData/${appContext.userToken}/$name';

      await restClient.post(url,
          body: json.encode(paramJson['ParameterValue']));
    } else {
      final value = Uri.encodeFull(paramJson['ParameterValue'] as String);
      final url =
          '${settings.backendUrl}/SetParameterValue/${appContext.userToken}/$name/$value';

      await restClient.get(url);
    }
  }
}
