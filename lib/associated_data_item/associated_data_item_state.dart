import 'package:meta/meta.dart';
import '../models/associated_data/associated_data.dart';
import '../view_object/view_object.dart';

class AssociatedDataItemGenerated extends ViewObjectState {
  final List<ColumnDef> columnDefinitions;
  final AssociatedDataTable table;
  final BusinessObject viewObject;
  final String userToken;

  AssociatedDataItemGenerated({
    @required this.columnDefinitions,
    @required this.table,
    this.viewObject,
    this.userToken,
  })  : assert(columnDefinitions != null),
        assert(table != null),
        assert(viewObject != null),
        assert(userToken != null),
        super([columnDefinitions, table, viewObject, userToken]);

  AssociatedDataItemGenerated copyWith({
    List<ColumnDef> columnDefinitions,
    AssociatedDataTable table,
  }) {
    return AssociatedDataItemGenerated(
      columnDefinitions: columnDefinitions ?? this.columnDefinitions,
      table: table ?? this.table,
      viewObject: this.viewObject,
      userToken: this.userToken,
    );
  }

  @override
  String toString() => 'AssociatedDataItemGenerated';
}

class NoActiveContainerError extends ViewObjectState {
  @override
  String toString() => 'NoActiveContainerError';
}
