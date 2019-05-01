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
    return Kpi(
      group: json['KpiGroup'],
      name: json['KpiName'],
      value: json['Value'],
      previousValue: json['PreviousValue'],
      targetValue: json['TargetValue'],
      valueChange: json['ValueChange'],
      chartName: json['ChartName'],
      image: json['KPIImage'],
      indicator: json['KPIIndicator'],
      extraData1: json['ColumnKPIExtraData1'],
      extraData2: json['ColumnKPIExtraData2'],
      userText1: json['ColumnKPIUserText1'],
      userText2: json['ColumnKPIUserText2'],
    );
  }
}
