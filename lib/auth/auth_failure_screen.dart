import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

class AuthFailureScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthFailureScreenState();
}

class _AuthFailureScreenState extends State<AuthFailureScreen> {
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
                final _authBloc = Provider.of<AuthBloc>(context);

                _authBloc.add(Authenticate());
              },
            ),
          ],
        ),
      ),
    );
  }
}
