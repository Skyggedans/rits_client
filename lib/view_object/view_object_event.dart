import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';

@immutable
abstract class ViewObjectEvent extends Equatable {
  ViewObjectEvent([List props = const []]) : super(props);
}

class ReturnToViewObjectMainScreen<T extends ViewObject>
    extends ViewObjectEvent {
  final T viewObject;

  ReturnToViewObjectMainScreen(this.viewObject) : super([viewObject]);

  @override
  String toString() => 'ReturnToViewObjectMainScreen';
}

class GetFavoriteId<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;

  GetFavoriteId(this.viewObject) : super([viewObject]);

  @override
  String toString() => 'GetFavoriteId { viewObject: ${viewObject.name} }';
}

class GenerateViewObject<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;

  GenerateViewObject(this.viewObject) : super([viewObject]);

  @override
  String toString() => 'GenerateViewObject { viewObject: ${viewObject.name} }';
}

class AddFavorite<T extends ViewObject> extends ViewObjectEvent {
  final T viewObject;

  AddFavorite(this.viewObject) : super([viewObject]);

  @override
  String toString() => 'AddFavorite { viewObject: ${viewObject.name} }';
}

class RemoveFavorite<T extends ViewObject> extends ViewObjectEvent {
  final int favoriteId;

  RemoveFavorite(this.favoriteId) : super([favoriteId]);

  @override
  String toString() => 'RemoveFavorite { favoriteId: $favoriteId }';
}
