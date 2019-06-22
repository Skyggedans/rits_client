import 'package:equatable/equatable.dart';

class Table extends Equatable {
  final List<String> columns;
  final List<Map<String, dynamic>> rows;

  Table({this.columns, this.rows});
}
