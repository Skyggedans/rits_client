import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rits_client/models/comments/comments.dart';

@immutable
abstract class CommentsState extends Equatable {
  CommentsState([List props = const []]) : super(props);
}

class CommentsInProgress extends CommentsState {
  @override
  String toString() => 'CommentsUninitialized';
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

  CommentSelected({this.comment}) : super([comment]);
}

class CommentsError extends CommentsState {
  final String message;

  CommentsError({this.message}) : super([message]);

  @override
  String toString() => 'CommentsError { message: $message }';
}
