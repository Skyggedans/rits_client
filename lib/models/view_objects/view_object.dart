import 'package:equatable/equatable.dart';

class ViewObject extends Equatable {
  //final int id;
  final String name;
  final String title;
  final String itemType;
  final String hierarchyLevel;
  final String contentType;
  final String inputForm;

  ViewObject({
    //this.id,
    this.name,
    this.title,
    this.itemType,
    this.hierarchyLevel,
    this.contentType,
    this.inputForm,
  });

  factory ViewObject.fromJson(Map<String, dynamic> json) {
    return ViewObject(
      name: json['Name'] as String,
      title: json['Title'] as String,
      itemType: json['ItemTypeName'] as String,
      hierarchyLevel: json['HierachyLevel'] as String,
      contentType: json['ContentTypeName'] as String,
      inputForm: json['InputForm'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Title': title,
        'ItemTypeName': itemType,
        'HierarchyLevel': hierarchyLevel,
        'ContentTypeName': contentType,
        'InputForm': inputForm,
      };
}
