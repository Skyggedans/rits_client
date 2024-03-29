import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';

@immutable
abstract class SelectionEvent extends Equatable {
  SelectionEvent([List props = const []]) : super(props);
}

class FetchSelectionOptions extends SelectionEvent {
  final ViewObjectParameter param;

  FetchSelectionOptions({@required this.param}) : super([param]);

  @override
  String toString() => 'FetchSelectionOptions';
}

class UpdateSelection<T> extends SelectionEvent {
  final T option;

  UpdateSelection({@required this.option}) : super([option]);

  @override
  String toString() => 'UpdateSelection';
}
