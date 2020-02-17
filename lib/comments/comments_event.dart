import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/models/comments/comments.dart';

@immutable
abstract class CommentsEvent extends Equatable {
  CommentsEvent([List props = const []]) : super(props);
}

class FetchComments extends CommentsEvent {
  @override
  String toString() => 'FetchComments';
}

abstract class CommentActionEvent extends CommentsEvent {
  final Comment comment;

  CommentActionEvent(this.comment) : super([comment]);

  @override
  String toString() => '${runtimeType.toString()} { comment: ${comment.text} }';
}

class SelectComment extends CommentActionEvent {
  SelectComment({Comment comment}) : super(comment);
}

class AddComment extends CommentActionEvent {
  AddComment({Comment comment}) : super(comment);
}

class UpdateComment extends CommentActionEvent {
  UpdateComment({Comment comment}) : super(comment);
}

class RemoveComment extends CommentActionEvent {
  RemoveComment({Comment comment}) : super(comment);
}
