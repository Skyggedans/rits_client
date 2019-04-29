import 'package:equatable/equatable.dart';

class ViewObject extends Equatable {
  final String name;
  final String title;
  final String itemType;
  final String hierarchyLevel;
  final String contentType;
  final String inputForm;

  ViewObject({
    this.name,
    this.title,
    this.itemType,
    this.hierarchyLevel,
    this.contentType,
    this.inputForm,
  });

  factory ViewObject.fromJson(Map<String, dynamic> json) {
    return ViewObject(
      name: json['Name'],
      title: json['Title'],
      itemType: json['ItemTypeName'],
      hierarchyLevel: json['HierachyLevel'],
      contentType: json['ContentTypeName'],
      inputForm: json['InputForm'],
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
