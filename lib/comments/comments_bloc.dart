import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../models/comments/comments.dart';
import '../settings.dart' as settings;
import '../utils/errors.dart';
import '../utils/rest_client.dart';
import 'comments.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final RestClient restClient;

  CommentsBloc({@required this.restClient}) : assert(restClient != null);

  @override
  get initialState => CommentsInProgress();

  @override
  Stream<CommentsEvent> transform(Stream<CommentsEvent> events) {
    return (events as Observable<CommentsEvent>)
        .debounce(Duration(milliseconds: 500));
  }

  @override
  Stream<CommentsState> mapEventToState(CommentsEvent event) async* {
    if (event is FetchComments) {
      yield CommentsInProgress();

      try {
        final comments = await _fetchComments(event.userToken);

        yield CommentsLoaded(comments: comments);
      } on ApiError {
        yield CommentsError(message: 'Unable to fetch comments');
      }
    } else if (event is AddComment) {
      yield CommentsInProgress();

      try {
        await _addComment(event.comment, event.userToken);
        dispatch(FetchComments(userToken: event.userToken));
      } on ApiError {
        yield CommentsError(message: 'Unable to add comment');
      }
    } else if (event is UpdateComment) {
      yield CommentsInProgress();

      try {
        await _updateComment(event.comment, event.userToken);
        dispatch(FetchComments(userToken: event.userToken));
      } on ApiError {
        yield CommentsError(message: 'Unable to update comment');
      }
    } else if (event is RemoveComment) {
      yield CommentsInProgress();

      try {
        await _removeComment(event.comment, event.userToken);
        dispatch(FetchComments(userToken: event.userToken));
      } on ApiError {
        yield CommentsError(message: 'Unable to remove comment');
      }
    }
  }

  Future<List<Comment>> _fetchComments(String userToken) async {
    final url = '${settings.backendUrl}/GetVoiceToTextMemos/$userToken';
    final response = await restClient.get(url);
    final body = json.decode(response.body);

    return body.map<Comment>((comment) {
      return Comment.fromJson(comment);
    }).toList();
  }

  Future<Null> _addComment(Comment comment, String userToken) async {
    final url = '${settings.backendUrl}/AddVoiceToTextMemo/$userToken';

    final requestBody = {
      'Comment': comment.text,
    };

    await restClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<Null> _updateComment(Comment comment, String userToken) async {
    final url = '${settings.backendUrl}/UpdateVoiceToTextMemo/$userToken';

    final requestBody = {
      'CommentID': comment.id,
      'Comment': comment.text,
    };

    await restClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<Null> _removeComment(Comment comment, String userToken) {}
}
