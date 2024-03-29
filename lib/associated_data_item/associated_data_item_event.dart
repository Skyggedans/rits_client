import 'package:meta/meta.dart';
import 'package:rits_client/models/associated_data/associated_data.dart';
import 'package:rits_client/view_object/view_object.dart';

class AddRow extends ViewObjectEvent {
  final AssociatedDataTable table;
  final Map<String, dynamic> row;

  AddRow({@required this.table, @required this.row})
      : assert(table != null),
        assert(row != null),
        super([table, row]);

  @override
  String toString() => 'AddRow';
}

class UpdateRow extends ViewObjectEvent {
  final AssociatedDataTable table;
  final Map<String, dynamic> row;
  final int index;

  UpdateRow({@required this.table, @required this.row, @required this.index})
      : assert(table != null),
        assert(row != null),
        assert(index != null),
        super([table, row, index]);

  @override
  String toString() => 'UpdateRow { index: $index }';
}

class RemoveRow extends ViewObjectEvent {
  final AssociatedDataTable table;
  final int index;

  RemoveRow({@required this.table, @required this.index})
      : assert(table != null),
        assert(index != null),
        super([table, index]);

  @override
  String toString() => 'RemoveRow { index: $index }';
}

class SaveRows extends ViewObjectEvent {
  final AssociatedDataTable table;
  final BusinessObject viewObject;

  SaveRows({
    @required this.table,
    @required this.viewObject,
  })  : assert(table != null),
        assert(viewObject != null),
        super([table, viewObject]);

  @override
  String toString() => 'SaveRows';
}
