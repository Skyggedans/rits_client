import 'dart:async';
import 'package:meta/meta.dart';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/rest_client.dart';
import 'view_objects.dart';

class ViewObjectsBloc extends Bloc<ViewObjectsEvent, ViewObjectsState> {
  final ViewObjectsRepository viewObjectsRepository;

  ViewObjectsBloc({@required this.viewObjectsRepository})
      : assert(viewObjectsRepository != null);

  @override
  Stream<ViewObjectsState> transformStates(Stream<ViewObjectsState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  get initialState => ViewObjectsUninitialized();

  @override
  Stream<ViewObjectsState> mapEventToState(ViewObjectsEvent event) async* {
    if (event is FetchViewObjects) {
      try {
        if (state is ViewObjectsUninitialized) {
          final viewObjects = event.hierarchyLevel?.isNotEmpty == true
              ? await viewObjectsRepository.fetchHierarchyViewObjects(
                  event.project,
                  event.type,
                  event.hierarchyLevel,
                  event.userToken,
                )
              : await viewObjectsRepository.fetchViewObjects(
                  event.project,
                  event.type,
                  event.userToken,
                );

          yield ViewObjectsLoaded(
              viewObjects: viewObjects, userToken: event.userToken);
        }
      } on ApiError {
        yield ViewObjectsError();
      }
    }
  }
}
