import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ViewObjectState extends Equatable {
  ViewObjectState([List props = const []]) : super(props);
}

class ViewObjectUninitialized extends ViewObjectState {
  @override
  String toString() => 'ViewObjectUninitialized';
}

class ViewObjectIdle extends ViewObjectState {
  final int favoriteId;
  final bool hasParams;

  ViewObjectIdle({this.favoriteId, this.hasParams})
      : super([favoriteId, hasParams]);

  @override
  String toString() =>
      'ViewObjectIdle { favoriteId: $favoriteId, hasParams: $hasParams }';
}

class ViewObjectGeneration extends ViewObjectState {
  @override
  String toString() => 'ViewObjectGeneration';
}

class ViewObjectGenerated extends ViewObjectState {
  @override
  String toString() => 'ViewObjectGenerated';
}

class ViewObjectError extends ViewObjectState {
  @override
  String toString() => 'ViewObjectError';
}
