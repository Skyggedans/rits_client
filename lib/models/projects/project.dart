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
      name: json['Name'],
      templateGuid: json['TemplateGUID'],
      luisId: json['LuisID'],
      templateName: json['TemplateName'],
    );
  }
}
