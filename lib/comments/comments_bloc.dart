import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../models/comments/comments.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';
import 'comments.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final RestClient restClient;

  CommentsBloc({@required this.restClient}) : assert(restClient != null);

  @override
  get initialState => CommentsInProgress();

  @override
  Stream<CommentsState> transformStates(Stream<CommentsState> states) {
    return states.debounceTime(Duration(milliseconds: 50));
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
        add(FetchComments(userToken: event.userToken));
      } on ApiError {
        yield CommentsError(message: 'Unable to add comment');
      }
    } else if (event is UpdateComment) {
      yield CommentsInProgress();

      try {
        await _updateComment(event.comment, event.userToken);
        add(FetchComments(userToken: event.userToken));
      } on ApiError {
        yield CommentsError(message: 'Unable to update comment');
      }
    } else if (event is RemoveComment) {
      yield CommentsInProgress();

      try {
        await _removeComment(event.comment, event.userToken);
        add(FetchComments(userToken: event.userToken));
      } on ApiError {
        yield CommentsError(message: 'Unable to remove comment');
      }
    }
  }

  Future<List<Comment>> _fetchComments(String userToken) async {
    final url = '${settings.backendUrl}/GetVoiceToTextMemos/$userToken';
    final response = await restClient.get(url);
    final body =
        List<Map<String, dynamic>>.from(json.decode(response.body) as List);

    return body.map((comment) {
      return Comment.fromJson(comment);
    }).toList();
  }

  Future<void> _addComment(Comment comment, String userToken) async {
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

  Future<void> _updateComment(Comment comment, String userToken) async {
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

  Future<void> _removeComment(Comment comment, String userToken) {
    return null;
  }
}
