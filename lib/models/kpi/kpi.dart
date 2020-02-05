import 'package:equatable/equatable.dart';

class Kpi extends Equatable {
  final String group;
  final String name;
  final num value;
  final num previousValue;
  final num targetValue;
  final num valueChange;
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
      group: json['KpiGroup'] as String,
      name: json['KpiName'] as String,
      value: json['Value'] as num,
      previousValue: json['PreviousValue'] as num,
      targetValue: json['TargetValue'] as num,
      valueChange: json['ValueChange'] as num,
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
