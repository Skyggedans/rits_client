import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rits_client/comments/comments_event.dart';
import 'package:rits_client/comments/comments_state.dart';
import 'package:rxdart/rxdart.dart';

import '../models/comments/comments.dart';
import '../settings.dart' as settings;
import '../utils/rest_client.dart';

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
        yield CommentsError();
      }
    }
  }

  Future<List<Comment>> _fetchComments(String userToken) async {
    final url = '${settings.backendUrl}/GetVoiceToTextMemo/$userToken';
    // final response = await restClient.get(url);
    // final body = json.decode(response.body);

    // return body.map<Comment>((comment) {
    //   return Comment.fromJson(comment);
    // }).toList();
    return Future.delayed(Duration(seconds: 3), () {
      return [
        Comment(text: 'comment 1'),
        Comment(text: 'comment 2'),
      ];
    });
  }
}
