import 'dart:typed_data';

import '../view_object/view_object.dart';

class ChartGenerated extends ViewObjectState {
  final Uint8List bytes;

  ChartGenerated({this.bytes}) : super([bytes]);

  @override
  String toString() => 'ChartGenerated';
}
