import 'package:equatable/equatable.dart';

class Report extends Equatable {
  final String name;
  final String title;
  final String itemType;
  final String contentType;
  final String inputForm;

  Report({
    this.name,
    this.title,
    this.itemType,
    this.contentType,
    this.inputForm,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      name: json['Name'] as String,
      title: json['Title'] as String,
      itemType: json['ItemTypeName'] as String,
      contentType: json['ContentTypeName'] as String,
      inputForm: json['InputForm'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Title': title,
        'ItemTypeName': itemType,
        'ContentTypeName': contentType,
        'InputForm': inputForm
      };
}
