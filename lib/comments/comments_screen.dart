import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/models/comments/comment.dart';
import 'package:rits_client/utils/utils.dart';
import 'package:rw_help/rw_help.dart';

import 'comments.dart';

abstract class CommentAction {
  final Comment comment;

  CommentAction(this.comment);
}

class SaveAction extends CommentAction {
  SaveAction({@required Comment comment})
      : assert(comment != null),
        super(comment);
}

class RemoveAction extends CommentAction {
  RemoveAction({@required Comment comment})
      : assert(comment != null),
        super(comment);
}

class CancelAction extends CommentAction {
  CancelAction() : super(null);
}

class CommentsScreen extends StatefulWidget {
  @override
  State createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  CommentsBloc _bloc;
  bool isRealWearDevice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      isRealWearDevice = Provider.of<AppConfig>(context).isRealWearDevice;

      _bloc = CommentsBloc(
        restClient: Provider.of<RestClient>(context),
        appContext: Provider.of<AppContext>(context),
      )..add(FetchComments());
    }
  }

  @override
  void dispose() {
    if (isRealWearDevice) {
      RwHelp.setCommands([]);
    }

    _bloc?.close();
    super.dispose();
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
            onPressed: () {
              _onAddCommentPressed(context);
            },
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _bloc,
          builder: (BuildContext context, CommentsState state) {
            if (state is CommentsInProgress) {
              return CircularProgressIndicator();
            } else if (state is CommentsLoaded) {
              return _buildComments(context, state);
            } else if (state is CommentsError) {
              return Text(state.message);
            }

            return const Text('Unable to fetch comments');
          },
        ),
      ),
    );
  }

  Widget _buildComments(BuildContext context, CommentsLoaded state) {
    final comments = state.comments;

    if (isRealWearDevice) {
      if (comments.isNotEmpty) {
        final commentsRange =
            comments.length == 1 ? '1' : '1-${comments.length}';

        RwHelp.setCommands(
            ['Say "Select comment $commentsRange" for comment actions']);
      } else {
        RwHelp.setCommands([]);
      }
    }

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
                leading: SizedBox(
                  width: 50,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.comment),
                      Text('${index + 1}'),
                    ],
                  ),
                ),
                title: Text(comment.text),
              ),
            ),
            onTap: () => _onCommentTap(
              context,
              comment,
            ),
          ),
          onTap: () => _onCommentTap(
            context,
            comment,
          ),
        );
      },
    );
  }

  void _onAddCommentPressed(BuildContext context) async {
    final newComment = Comment();
    final dialogResult = await _showCommentDialog(context, newComment);

    if (dialogResult is SaveAction) {
      _bloc.add(AddComment(comment: dialogResult.comment));
    }
  }

  void _onCommentTap(BuildContext context, Comment comment) async {
    final dialogResult = await _showCommentDialog(context, comment);

    if (dialogResult is SaveAction) {
      _bloc.add(UpdateComment(comment: dialogResult.comment));
    } else if (dialogResult is RemoveAction) {
      _bloc.add(RemoveComment(comment: dialogResult.comment));
    }
  }

  Future<CommentAction> _showCommentDialog(
      BuildContext context, Comment comment) async {
    final formKey = GlobalKey<FormState>();
    Comment modifiedComment;

    return await showDialog<CommentAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: comment.text,
              maxLines: null,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              onSaved: (value) {
                modifiedComment = comment.copyWith(text: value);
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(CancelAction());
              },
            ),
            FlatButton(
              child: const Text('SAVE'),
              onPressed: () {
                formKey.currentState.save();
                Navigator.of(context)
                    .pop(SaveAction(comment: modifiedComment ?? comment));
              },
            ),
          ],
        );
      },
    );
  }
}
