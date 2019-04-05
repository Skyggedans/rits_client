import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'RITS for HMT-1 Demonstration',
          style: TextStyle(
            fontSize: 24
          ),
        ),
      ),
    );
  }
}
