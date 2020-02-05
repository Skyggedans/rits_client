import 'package:rits_client/models/view_objects/view_object.dart';

class BusinessObject extends ViewObject {
  final int id;
  // final String name;

  BusinessObject({this.id, String name}) : super(name: name);

  factory BusinessObject.fromJson(Map<String, dynamic> json) {
    return BusinessObject(
      id: json['BusinessObjectID'] as int,
      name: json['BoName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'BusinessObjectID': id,
        'BoName': name,
      };
}
