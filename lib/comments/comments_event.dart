import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:rits_client/models/comments/comments.dart';

abstract class CommentsEvent extends Equatable {
  CommentsEvent([List props = const []]) : super(props);
}

class FetchComments extends CommentsEvent {
  final String userToken;

  FetchComments({@required this.userToken}) : assert(userToken != null);

  @override
  String toString() => 'FetchComments';
}

abstract class CommentActionEvent extends CommentsEvent {
  final Comment comment;
  final String userToken;

  CommentActionEvent(this.comment, this.userToken)
      : super([comment, userToken]);

  @override
  String toString() => '${runtimeType.toString()} { comment: ${comment.text} }';
}

class SelectComment extends CommentActionEvent {
  SelectComment({Comment comment, String userToken})
      : super(comment, userToken);
}

class AddComment extends CommentActionEvent {
  AddComment({Comment comment, String userToken}) : super(comment, userToken);
}

class UpdateComment extends CommentActionEvent {
  UpdateComment({Comment comment, String userToken})
      : super(comment, userToken);
}

class RemoveComment extends CommentActionEvent {
  RemoveComment({Comment comment, String userToken})
      : super(comment, userToken);
}
