import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

class ReportParameter extends Equatable {
  final String name;
  final String title;
  final String viewItem;
  final String itemType;
  final dynamic value;
  final String dataType;
  final String selectionMode;
  final bool readOnly;

  ReportParameter(
      {this.name,
      this.title,
      this.viewItem,
      this.itemType,
      this.value,
      this.dataType,
      this.selectionMode,
      this.readOnly})
      : super([
          name,
          title,
          viewItem,
          itemType,
          value,
          dataType,
          selectionMode,
          readOnly
        ]);

  factory ReportParameter.fromJson(Map<String, dynamic> json) {
    dynamic paramValue;

    switch (json['DataType']) {
      case 'DateTime':
        {
          final DateFormat format = DateFormat('MM/dd/yyyy');

          paramValue = format.parse(json['ParameterValue']);

          break;
        }
      default:
        {
          paramValue = json['ParameterValue'];
        }
    }

    return ReportParameter(
        name: json['ParameterName'],
        title: json['Title'],
        viewItem: json['ViewItemName'],
        itemType: json['ItemTypeName'],
        value: paramValue,
        dataType: json['DataType'],
        selectionMode: json['SelectionMode'],
        readOnly: json['ReadOnly'].toLowerCase() == 'true');
  }

  Map<String, dynamic> toJson() {
    String paramValue;

    switch (dataType) {
      case 'DateTime': {
        paramValue = DateFormat('yyyy-MM-dd').format(value);

        break;
      }
      default: {
        paramValue = value;
      }
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

  ReportParameter copyWith({
    dynamic value,
  }) {
    return ReportParameter(
      name: name,
      title: title,
      viewItem: viewItem,
      itemType: itemType,
      value: value ?? this.value,
      dataType: dataType,
      selectionMode: selectionMode,
      readOnly: readOnly
    );
  }
}
