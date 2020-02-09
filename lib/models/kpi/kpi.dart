import 'package:equatable/equatable.dart';

class Kpi extends Equatable {
  final String group;
  final String name;
  final dynamic value;
  final dynamic previousValue;
  final dynamic targetValue;
  final dynamic valueChange;
  final String chartName;
  final String image;
  final int indicator;
  final dynamic extraData1;
  final dynamic extraData2;
  final String userText1;
  final String userText2;

  Kpi({
    this.group,
    this.name,
    this.value,
    this.previousValue,
    this.targetValue,
    this.valueChange,
    this.chartName,
    this.image,
    this.indicator,
    this.extraData1,
    this.extraData2,
    this.userText1,
    this.userText2,
  }) : super([
          group,
          name,
          value,
          previousValue,
          targetValue,
          valueChange,
          chartName,
          image,
          indicator,
          extraData1,
          extraData2,
          userText1,
          userText2,
        ]);

  factory Kpi.fromJson(Map<String, dynamic> json) {
    dynamic value = json['Value'] is num
        ? json['Value']
        : num.tryParse(json['Value'] as String ?? '');

    if (value == null) {
      value = DateTime.tryParse(json['Value'] as String ?? '');
    }

    dynamic previousValue = json['PreviousValue'] is num
        ? json['PreviousValue']
        : num.tryParse(json['PreviousValue'] as String ?? '');

    if (previousValue == null) {
      previousValue = DateTime.tryParse(json['PreviousValue'] as String ?? '');
    }

    dynamic targetValue = json['TargetValue'] is num
        ? json['TargetValue']
        : num.tryParse(json['TargetValue'] as String ?? '');

    if (targetValue == null) {
      targetValue = DateTime.tryParse(json['TargetValue'] as String ?? '');
    }

    dynamic valueChange = json['ValueChange'] is num
        ? json['ValueChange']
        : num.tryParse(json['ValueChange'] as String ?? '');

    if (valueChange == null) {
      valueChange = DateTime.tryParse(json['ValueChange'] as String ?? '');
    }

    return Kpi(
      group: json['KpiGroup'] as String,
      name: json['KpiName'] as String,
      value: value ?? json['Value'],
      previousValue: previousValue ?? json['PreviousValue'],
      targetValue: targetValue ?? json['TargetValue'],
      valueChange: valueChange ?? json['ValueChange'],
      chartName: json['ChartName'] as String,
      image: json['KPIImage'] as String,
      indicator: json['KPIIndicator'] as int,
      extraData1: json['ColumnKPIExtraData1'],
      extraData2: json['ColumnKPIExtraData2'],
      userText1: json['ColumnKPIUserText1'] as String,
      userText2: json['ColumnKPIUserText2'] as String,
    );
  }
}
