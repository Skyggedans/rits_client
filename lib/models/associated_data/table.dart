import 'package:equatable/equatable.dart';

class AssociatedDataTable extends Equatable {
  final List<String> columns;
  final List<Map<String, dynamic>> rows;

  AssociatedDataTable({this.columns, this.rows});
}
