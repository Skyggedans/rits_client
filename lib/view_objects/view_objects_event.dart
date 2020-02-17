import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ViewObjectsEvent extends Equatable {
  ViewObjectsEvent([List props = const []]) : super(props);
}

class FetchViewObjects extends ViewObjectsEvent {
  final String type;
  final bool favorite;

  FetchViewObjects({
    this.type,
    this.favorite,
  }) : super([type, favorite]);

  @override
  String toString() => 'FetchViewObjects { type: $type }';
}
