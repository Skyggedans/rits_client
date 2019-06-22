import 'package:rits_client/models/associated_data/associated_data.dart';

import '../view_object/view_object.dart';

class AssociatedDataItemGenerated extends ViewObjectState {
  final List<ColumnDef> columns;
  final Table table;

  AssociatedDataItemGenerated({this.columns, this.table})
      : super([columns, table]);

  @override
  String toString() => 'AssociatedDataItemGenerated';
}
