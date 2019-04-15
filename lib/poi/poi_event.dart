import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class PoiEvent extends Equatable {
  PoiEvent([List props = const []]) : super(props);
}

class ScanItem extends PoiEvent {
  final String userToken;

  ScanItem({@required this.userToken}) : super([userToken]);

  @override
  String toString() => 'ScanItem';
}
