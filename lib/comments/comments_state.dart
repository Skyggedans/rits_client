import 'package:equatable/equatable.dart';

import 'package:rits_client/models/comments/comments.dart';

abstract class CommentsState extends Equatable {
  CommentsState([List props = const []]) : super(props);
}

class CommentsInProgress extends CommentsState {
  @override
  String toString() => 'CommentsUninitialized';
}

class CommentsError extends CommentsState {
  @override
  String toString() => 'CommentsError';
}

class CommentsLoaded extends CommentsState {
  final List<Comment> comments;

  CommentsLoaded({
    this.comments,
  }) : super([comments]);

  CommentsLoaded copyWith({
    List<Comment> comments,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
    );
  }

  @override
  String toString() => 'CommentsLoaded { comments: ${comments.length} }';
}

class CommentSelected extends CommentsState {
  final Comment comment;
  final String userToken;

  CommentSelected({this.comment, this.userToken}) : super([comment, userToken]);
}
