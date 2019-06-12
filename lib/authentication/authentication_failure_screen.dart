import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'authentication.dart';

class AuthenticationFailureScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthenticationFailureScreenState();
}

class _AuthenticationFailureScreenState
    extends State<AuthenticationFailureScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorization Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('Access not granted or authorization is timed out'),
            RaisedButton(
              child: const Text('Try Again'),
              onPressed: () {
                final _authBloc = BlocProvider.of<AuthenticationBloc>(context);
                _authBloc.dispatch(Authenticate());
              },
            ),
          ],
        ),
      ),
    );
  }
}
