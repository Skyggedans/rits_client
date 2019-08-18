import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Comment extends Equatable {
  final int id;
  final String text;

  Comment({this.id, @required this.text})
      : assert(text != null),
        super([id, text]);

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['CommentID'],
      text: json['Comment'],
    );
  }

  Map<String, dynamic> toJson() => {
        'CommentID': id,
        'Comment': text,
      };
}
