import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class ViewObjectState extends Equatable {
  ViewObjectState([List props = const []]) : super(props);
}

class ViewObjectIdle extends ViewObjectState {
  @override
  String toString() => 'ViewObjectIdle';
}

class ViewObjectGeneration extends ViewObjectState {
  @override
  String toString() => 'ViewObjectGeneration';
}

class ViewObjectGenerated extends ViewObjectState {
  final Uint8List bytes;
  final dynamic data;

  ViewObjectGenerated({this.bytes, this.data}) : super([bytes, data]);

  @override
  String toString() => 'ViewObjectGenerated';
}

class ViewObjectError extends ViewObjectState {
  @override
  String toString() => 'ViewObjectError';
}
