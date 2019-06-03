import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rw_speech_recognizer/rw_speech_recognizer.dart';

import 'utils/rest_client.dart';
import 'splash/splash.dart';
import 'projects/projects.dart';
import 'authentication/authentication.dart';
import 'login/login.dart';
import 'user_code/user_code.dart';
import 'user_repository/user_repository.dart';
import 'routes.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
  }
}

class _HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

main() {
  final userRepository = UserRepository();

  //BlocSupervisor().delegate = SimpleBlocDelegate();
  HttpOverrides.global = _HttpOverrides();
  RestClient(userRepository: userRepository);

  RwSpeechRecognizer.setCommands(<String>['Test'], (command) {
    command;
  });

  runApp(RitsApp(userRepository: userRepository));
}

class RitsApp extends StatefulWidget {
  final UserRepository userRepository;

  RitsApp({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<RitsApp> createState() => _RitsAppState();
}

class _RitsAppState extends State<RitsApp> with BlocDelegate {
  AuthenticationBloc _authenticationBloc;

  _RitsAppState() {
    BlocSupervisor().delegate = this;
  }

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      bloc: _authenticationBloc,
      child: MaterialApp(
        routes: routes,
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized) {
              return SplashScreen();
            } else if (state is AuthenticationPending) {
              return UserCodeScreen(
                verificationUrl: state.verificationUrl,
                userCode: state.userCode,
              );
            } else if (state is Authenticated) {
              return ProjectsScreen();
            } else if (state is Unauthenticated) {
              return LoginScreen(userRepository: _userRepository);
            } else if (state is AuthenticationLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        // theme: ThemeData(
        //   textTheme: TextTheme(
        //     body1: TextStyle(fontSize: 20.0),
        //     body2: TextStyle(fontSize: 20.0),
        //     subhead: TextStyle(fontSize: 20.0),
        //     button: TextStyle(fontSize: 20.0),
        //     caption: TextStyle(fontSize: 20.0),
        //   ),
        // ),
      ),
    );
  }

  @override
  void onTransition(Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);

    if (error is TokenExpiredError) {
      _authenticationBloc.dispatch(AccessTokenExpired());
    }
  }
}
