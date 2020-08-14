import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/comments/comments.dart';
import 'package:rits_client/settings.dart' as settings;
import 'package:rits_client/utils/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import 'comments.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final RestClient restClient;
  final AppContext appContext;

  CommentsBloc({@required this.restClient, @required this.appContext})
      : assert(restClient != null),
        assert(appContext != null),
        super(CommentsInProgress());

  @override
  Stream<CommentsState> transformStates(Stream<CommentsState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
  }

  @override
  Stream<CommentsState> mapEventToState(CommentsEvent event) async* {
    if (event is FetchComments) {
      yield CommentsInProgress();

      try {
        final comments = await _fetchComments();

        yield CommentsLoaded(comments: comments);
      } on ApiError {
        yield CommentsError(message: 'Unable to fetch comments');
      }
    } else if (event is AddComment) {
      yield CommentsInProgress();

      try {
        await _addComment(event.comment);
        add(FetchComments());
      } on ApiError {
        yield CommentsError(message: 'Unable to add comment');
      }
    } else if (event is UpdateComment) {
      yield CommentsInProgress();

      try {
        await _updateComment(event.comment);
        add(FetchComments());
      } on ApiError {
        yield CommentsError(message: 'Unable to update comment');
      }
    } else if (event is RemoveComment) {
      yield CommentsInProgress();

      try {
        await _removeComment(event.comment);
        add(FetchComments());
      } on ApiError {
        yield CommentsError(message: 'Unable to remove comment');
      }
    }
  }

  Future<List<Comment>> _fetchComments() async {
    final url =
        '${settings.backendUrl}/GetVoiceToTextMemos/${appContext.userToken}';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((comment) {
      return Comment.fromJson(comment);
    }).toList();
  }

  Future<void> _addComment(Comment comment) async {
    final url =
        '${settings.backendUrl}/AddVoiceToTextMemo/${appContext.userToken}';

    final requestBody = {
      'Comment': comment.text,
    };

    await restClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<void> _updateComment(Comment comment) async {
    final url =
        '${settings.backendUrl}/UpdateVoiceToTextMemo/${appContext.userToken}';

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

  Future<void> _removeComment(Comment comment) {
    return null;
  }
}
