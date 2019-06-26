import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class AssociatedDataContainer extends Equatable {
  final int id;
  final String name;

  AssociatedDataContainer({
    @required this.id,
    @required this.name,
  })  : assert(id != null),
        assert(name != null);

  factory AssociatedDataContainer.fromJson(Map<String, dynamic> json) {
    return AssociatedDataContainer(
      id: json['AssociatedHeaderID'],
      name: json['AssociatedHeaderName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'AssociatedHeaderID': id,
        'AssociatedHeaderName': name,
      };
}
