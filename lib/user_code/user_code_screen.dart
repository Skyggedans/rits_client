import 'package:flutter/material.dart';

class UserCodeScreen extends StatelessWidget {
  final String userCode;
  final String verificationUrl;

  UserCodeScreen(
      {Key key, @required this.userCode, @required this.verificationUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorization'),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please navigate to',
              textAlign: TextAlign.center,
            ),
            Text(
              verificationUrl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'and enter the code displayed below:',
              textAlign: TextAlign.center,
            ),
            Text(
              userCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
