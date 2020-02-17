import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/associated_data/associated_data.dart';

class AssociatedDataTable extends Equatable {
  final AssociatedDataContainer container;
  final List<String> columns;
  final List<Map<String, dynamic>> rows;

  AssociatedDataTable({
    @required this.container,
    @required this.columns,
    @required this.rows,
  })  : assert(container != null),
        assert(columns != null),
        assert(rows != null);
}
