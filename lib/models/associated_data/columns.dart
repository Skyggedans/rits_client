import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

abstract class ColumnDef<T> extends Equatable {
  final String name;
  final T min;
  final T max;
  final List<T> options;

  T get defaultValue;

  ColumnDef(this.name, {this.min, this.max, this.options});

  factory ColumnDef.fromJson(Map<String, dynamic> json) {
    switch (json['AttributeTypeName']) {
      case 'Numeric':
        {
          return NumericColumn.fromJson(json) as ColumnDef<T>;
        }
      case 'Text':
        {
          return StringColumn.fromJson(json) as ColumnDef<T>;
        }
      case 'Date':
        {
          return DateTimeColumn.fromJson(json) as ColumnDef<T>;
        }
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
        'AttributeName': name,
        'InclusionMin': min,
        'InclusionMax': min,
        'Items': options
      };
}

class NumericColumn extends ColumnDef<num> {
  NumericColumn(String name, {num min, num max, List<num> options})
      : super(name, min: min, max: max, options: options);

  num get defaultValue => 0;

  factory NumericColumn.fromJson(Map<String, dynamic> json) {
    return NumericColumn(
      json['AttributeName'],
      min: json['InclusionMin'],
      max: json['InclusionMax'],
      options: json['Items']?.cast<num>(),
    );
  }
}

class StringColumn extends ColumnDef<String> {
  StringColumn(String name, {List<String> options})
      : super(name, options: options);

  String get defaultValue => '';

  factory StringColumn.fromJson(Map<String, dynamic> json) {
    return StringColumn(
      json['AttributeName'],
      options: json['Items']?.cast<String>(),
    );
  }
}

class DateTimeColumn extends ColumnDef<DateTime> {
  DateTimeColumn(String name, {DateTime min, DateTime max})
      : super(name, min: min, max: max);

  DateTime get defaultValue => DateTime.now();

  factory DateTimeColumn.fromJson(Map<String, dynamic> json) {
    final DateFormat format = DateFormat('MM/dd/yyyy hh:mm:ss a');
    DateTime min;
    DateTime max;

    try {
      min = format.parse(json['InclusionMin']);
    } catch (_) {
      min = null;
    }

    try {
      max = format.parse(json['InclusionMax']);
    } catch (_) {
      max = null;
    }

    return DateTimeColumn(
      json['AttributeName'],
      min: min,
      max: max,
    );
  }
}
