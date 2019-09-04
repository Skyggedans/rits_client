import 'dart:typed_data';

import 'package:rits_client/view_object/view_object.dart';

class ReportGenerated extends ViewObjectState {
  final Uint8List bytes;

  ReportGenerated({this.bytes}) : super([bytes]);

  @override
  String toString() => 'ReportGenerated';
}
