import 'package:equatable/equatable.dart';

class QnaStatusItem extends Equatable {
  final String name;
  final String type;
  final String url;

  QnaStatusItem({this.name, this.type, this.url})
      : assert(name != null),
        assert(type != null),
        super([name, type, url]);

  factory QnaStatusItem.fromJson(Map<String, dynamic> json) {
    return QnaStatusItem(
      name: json['Name'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
    );
  }
}
