import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String name;
  final String templateGuid;
  final String luisId;
  final String templateName;

  Project({this.name, this.templateGuid, this.luisId, this.templateName})
      : super([name, templateGuid, luisId, templateName]);

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['Name'] as String,
      templateGuid: json['TemplateGUID'] as String,
      luisId: json['LuisID'] as String,
      templateName: json['TemplateName'] as String,
    );
  }
}
