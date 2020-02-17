import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SelectionState extends Equatable {
  SelectionState([List props = const []]) : super(props);
}

class SelectionOptionsUninitialized extends SelectionState {
  @override
  String toString() => 'SelectionOptionsUninitialized';
}

class SelectionOptionsLoaded<T> extends SelectionState {
  final List<T> options;
  final T selection;

  SelectionOptionsLoaded({
    @required this.options,
    this.selection,
  }) : super([options, selection]);

  SelectionOptionsLoaded copyWith({List<T> options, T selection}) {
    return SelectionOptionsLoaded(
        options: options ?? this.options,
        selection: selection ?? this.selection);
  }

  @override
  String toString() => 'SelectionOptionsLoaded { options: ${options.length} }';
}

class SelectionOptionsError extends SelectionState {
  @override
  String toString() => 'SelectionOptionsError';
}
