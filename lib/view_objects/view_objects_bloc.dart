import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../utils/utils.dart';
import 'view_objects.dart';

class ViewObjectsBloc extends Bloc<ViewObjectsEvent, ViewObjectsState> {
  final ViewObjectsRepository viewObjectsRepository;

  ViewObjectsBloc({@required this.viewObjectsRepository})
      : assert(viewObjectsRepository != null);

  @override
  Stream<ViewObjectsEvent> transform(Stream<ViewObjectsEvent> events) {
    return (events as Observable<ViewObjectsEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  get initialState => ViewObjectsUninitialized();

  @override
  Stream<ViewObjectsState> mapEventToState(ViewObjectsEvent event) async* {
    if (event is FetchViewObjects) {
      try {
        if (currentState is ViewObjectsUninitialized) {
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

          yield ViewObjectsLoaded(viewObjects: viewObjects);
        }
      } on ApiError {
        yield ViewObjectsError();
      }
    }
  }
}
