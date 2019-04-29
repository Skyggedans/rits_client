import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class PoiState extends Equatable {
  PoiState([List props = const []]) : super(props);
}

class PoiUninitialized extends PoiState {
  @override
  String toString() => 'PoiUninitialized';
}

class ItemScanned extends PoiState {
  final String itemInfo;
  final String levelName;
  final String userToken;

  ItemScanned({
    @required this.itemInfo,
    @required this.levelName,
    @required this.userToken,
  }) : super([itemInfo, levelName, userToken]);

  @override
  String toString() => 'ItemScanned { info: $itemInfo, level: $levelName }';
}

class PoiError extends PoiState {
  final String itemInfo;

  PoiError({@required this.itemInfo}) : super([itemInfo]);

  @override
  String toString() => 'PoiError {info: $itemInfo}';
}
