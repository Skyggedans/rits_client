import 'package:rits_client/view_object/view_object.dart';

class TabularDataGenerated extends ViewObjectState {
  final List<dynamic> data;

  TabularDataGenerated({this.data}) : super([data]);

  @override
  String toString() => 'TabularDataGenerated';
}
