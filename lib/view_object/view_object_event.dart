import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import '../models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectEvent extends Equatable {
  ViewObjectEvent([List props = const []]) : super(props);
}

class ReturnToViewObjectMainScreen<T extends ViewObject>
    extends ViewObjectEvent {
  final T viewObject;
  final String userToken;

  ReturnToViewObjectMainScreen(this.viewObject, this.userToken)
      : super([viewObject, userToken]);

  @override
  String toString() => 'ReturnToViewObjectMainScreen';
}

class GetFavoriteId<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;
  final String userToken;

  GetFavoriteId(this.viewObject, this.userToken)
      : super([viewObject, userToken]);

  @override
  String toString() => 'GetFavoriteId { viewObject: ${viewObject.name} }';
}

class GenerateViewObject<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;
  final String userToken;

  GenerateViewObject(this.viewObject, this.userToken)
      : super([viewObject, userToken]);

  @override
  String toString() => 'GenerateViewObject { viewObject: ${viewObject.name} }';
}

class AddFavorite<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;
  final String userToken;

  AddFavorite(this.viewObject, this.userToken) : super([viewObject, userToken]);

  @override
  String toString() => 'AddFavorite { viewObject: ${viewObject.name} }';
}

class RemoveFavorite<T extends ViewObject> extends ViewObjectEvent {
  final int favoriteId;
  final String userToken;

  RemoveFavorite(this.favoriteId, this.userToken)
      : super([favoriteId, userToken]);

  @override
  String toString() => 'RemoveFavorite { favoriteId: $favoriteId }';
}
