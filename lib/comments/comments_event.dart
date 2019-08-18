import 'package:equatable/equatable.dart';

import '../models/comments/comments.dart';
import 'package:meta/meta.dart';

abstract class CommentsEvent extends Equatable {
  CommentsEvent([List props = const []]) : super(props);
}

class SelectComment extends CommentsEvent {
  final Comment comment;

  SelectComment(this.comment) : super([comment]);

  @override
  String toString() => 'SelectComment { comment: ${comment.text} }';
}

class FetchComments extends CommentsEvent {
  final String userToken;

  FetchComments({@required this.userToken}) : assert(userToken != null);

  @override
  String toString() => 'FetchComments';
}
