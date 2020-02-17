import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'view_objects.dart';

class ViewObjectsBloc extends Bloc<ViewObjectsEvent, ViewObjectsState> {
  final ViewObjectsRepository viewObjectsRepository;
  final AppContext appContext;

  ViewObjectsBloc({
    @required this.viewObjectsRepository,
    @required this.appContext,
  })  : assert(viewObjectsRepository != null),
        assert(appContext != null),
        super();

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
          final viewObjects = !event.favorite
              ? (appContext.sessionContextName?.isNotEmpty == true
                  ? await viewObjectsRepository
                      .fetchHierarchyViewObjects(event.type)
                  : await viewObjectsRepository.fetchViewObjects(event.type))
              : await viewObjectsRepository
                  .fetchFavoriteViewObjects(event.type);

          yield ViewObjectsLoaded(viewObjects: viewObjects);
        }
      } on ApiError {
        yield ViewObjectsError();
      }
    }
  }
}
