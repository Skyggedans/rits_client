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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Please navigate to $verificationUrl and enter the code displayed below:',
            textAlign: TextAlign.center,
          ),
          Text(
            userCode,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
