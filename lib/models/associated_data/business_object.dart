import '../../models/view_objects/view_object.dart';

class BusinessObject extends ViewObject {
  final int id;
  // final String name;

  BusinessObject({this.id, String name}) : super(name: name);

  factory BusinessObject.fromJson(Map<String, dynamic> json) {
    return BusinessObject(
      id: json['BusinessObjectID'],
      name: json['BoName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'BusinessObjectID': id,
        'BoName': name,
      };
}
