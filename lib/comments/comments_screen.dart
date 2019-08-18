import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:rits_client/comments/comments_event.dart';
import 'package:rits_client/models/comments/comment.dart';
import 'package:rits_client/utils/utils.dart';

import 'comments.dart';

class CommentsScreen extends StatefulWidget {
  final String userToken;

  CommentsScreen({
    Key key,
    @required this.userToken,
  }) : assert(userToken != null);

  @override
  State createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentsBloc = CommentsBloc(restClient: RestClient());

  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _commentsBloc.dispatch(FetchComments(userToken: _userToken));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        actions: <Widget>[
          FlatButton(
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                Text(
                  'NEW COMMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _commentsBloc,
          builder: (BuildContext context, CommentsState state) {
            if (state is CommentsInProgress) {
              return CircularProgressIndicator();
            } else if (state is CommentsLoaded) {
              return _buildComments(context, state);
            } else if (state is CommentsError) {
              return const Text('Unable to fetch comments');
            }
          },
        ),
      ),
    );
  }

  Widget _buildComments(BuildContext context, CommentsLoaded state) {
    final comments = state.comments;

    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];

        return InkWell(
          child: Semantics(
            button: true,
            value: 'Select Comment ${index + 1}',
            child: Card(
              child: ListTile(
                title: Text(comment.text),
              ),
            ),
            // onTap: () => _onCommentTap(
            //   context,
            //   comment,
            //   index,
            // ),
          ),
          // onTap: () => _onCommentTap(
          //   context,
          //   comment,
          //   index,
          // ),
        );
      },
    );
  }

  // void _onCommentTap(BuildContext context, Comment comment, int index) async {
  //   final dialogResult = await _showCommentDialog(context, comment, index);

  //   switch (dialogResult) {
  //     case RecordAction.EDIT:
  //       {
  //         final modifiedRow = await Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => RowEditorScreen(
  //               columnDefinitions: columnDefinitions,
  //               row: Map<String, dynamic>.from(comment),
  //             ),
  //           ),
  //         );

  //         if (modifiedRow != null) {
  //           viewObjectBloc.dispatch(
  //               UpdateRow(table: table, row: modifiedRow, index: index));
  //         }

  //         break;
  //       }
  //     case RecordAction.REMOVE:
  //       {
  //         viewObjectBloc.dispatch(RemoveRow(table: table, index: index));

  //         break;
  //       }
  //     default:
  //   }
  // }

  // Future<RecordAction> _showCommentDialog(
  //     BuildContext context, Comment comment, int index) async {
  //   return await showDialog<RecordAction>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Record ${index + 1}'),
  //         content: const Text('Select required action'),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: const Text('CANCEL'),
  //             onPressed: () {
  //               Navigator.of(context).pop(RecordAction.CANCEL);
  //             },
  //           ),
  //           FlatButton(
  //             child: const Text('EDIT'),
  //             onPressed: () {
  //               Navigator.of(context).pop(RecordAction.EDIT);
  //             },
  //           ),
  //           FlatButton(
  //             child: const Text('REMOVE'),
  //             onPressed: () {
  //               Navigator.of(context).pop(RecordAction.REMOVE);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
