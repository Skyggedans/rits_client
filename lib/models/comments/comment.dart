import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final String text;

  Comment({this.id, this.text: ''})
      : assert(text != null),
        super([id, text]);

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['CommentID'] as int,
      text: json['CommentText'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'CommentID': id,
        'CommentText': text,
      };

  Comment copyWith({
    String text,
  }) {
    return Comment(
      id: id,
      text: text ?? this.text,
    );
  }
}
