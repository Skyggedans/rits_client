import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

import 'view_objects.dart';

enum SelectionMode { none, one, multiselect }

class ViewObjectParameter extends Equatable {
  final String name;
  final String title;
  final String viewItem;
  final String itemType;
  final dynamic value;
  final String dataType;
  final String selectionMode;
  final bool readOnly;

  ViewObjectParameter({
    this.name,
    this.title,
    this.viewItem,
    this.itemType,
    this.value,
    this.dataType,
    this.selectionMode,
    this.readOnly,
  }) : super([
          name,
          title,
          viewItem,
          itemType,
          value,
          dataType,
          selectionMode,
          readOnly
        ]);

  factory ViewObjectParameter.fromJson(Map<String, dynamic> json) {
    final dataType = json['DataType'].toString().toLowerCase();
    dynamic value = json['ParameterValue'];

    switch (dataType) {
      case 'numeric':
        {
          final numValue =
              value is num ? value : double.tryParse(value as String);
          final truncatedValue = numValue.truncate();

          value = numValue == truncatedValue ? truncatedValue : numValue;

          break;
        }
      case 'date':
        {
          final DateFormat format = DateFormat('MM/dd/yyyy');

          value = format.parse(value as String);

          break;
        }
      case 'datetime':
        {
          final DateFormat format = DateFormat('MM/dd/yyyy hh:mm:ss a');

          value = format.parse(value as String);

          break;
        }
    }

    return ViewObjectParameter(
        name: json['ParameterName'] as String,
        title: json['Title'] as String,
        viewItem: json['ViewItemName'] as String,
        itemType: json['ItemTypeName'] as String,
        value: value,
        dataType: dataType,
        selectionMode: json['SelectionMode'].toString().toLowerCase(),
        readOnly: json['ReadOnly'].toLowerCase() == 'true');
  }

  Map<String, dynamic> toJson() {
    dynamic paramValue;

    if (selectionMode != 'multiselect') {
      switch (dataType) {
        case 'date':
          {
            paramValue = DateFormat('yyyy-MM-dd').format(value as DateTime);

            break;
          }
        case 'datetime':
          {
            paramValue =
                DateFormat('yyyy-MM-dd hh:mm:ss a').format(value as DateTime);

            break;
          }
        default:
          {
            paramValue = value.toString();
          }
      }
    } else {
      paramValue = List<Option>.from(value as List)
          .map((filter) => filter.toJson())
          .toList();
    }

    return {
      'ParameterName': name,
      'Title': title,
      'ViewItemName': viewItem,
      'ItemTypeName': itemType,
      'ParameterValue': paramValue,
      'DataType': dataType,
      'SelectionMode': selectionMode,
      'ReadOnly': readOnly
    };
  }

  ViewObjectParameter copyWith({
    String viewItem,
    String itemType,
    dynamic value,
  }) {
    return ViewObjectParameter(
        name: name,
        title: title,
        viewItem: viewItem ?? this.viewItem,
        itemType: itemType ?? this.itemType,
        value: value ?? this.value,
        dataType: dataType,
        selectionMode: selectionMode,
        readOnly: readOnly);
  }
}
