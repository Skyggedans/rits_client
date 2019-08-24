import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/app_config.dart';

import 'authentication/authentication.dart';
import 'projects/projects.dart';
import 'routes.dart';
import 'splash/splash.dart';
import 'utils/rest_client.dart';

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
  final authRepository = AuthRepository(authProvider: AuthProvider());

  HttpOverrides.global = _HttpOverrides();
  RestClient(authRepository: authRepository);

  // RwSpeechRecognizer.setCommands(<String>['Test'], (command) {
  //   command;
  // });

  runApp(
    AppConfig(
      child: RitsApp(authRepository: authRepository),
    ),
  );
}

class RitsApp extends StatefulWidget {
  final AuthRepository authRepository;

  RitsApp({Key key, @required this.authRepository}) : super(key: key);

  @override
  State<RitsApp> createState() => _RitsAppState();
}

class _RitsAppState extends State<RitsApp> with BlocDelegate {
  AuthenticationBloc _authenticationBloc;

  _RitsAppState() {
    BlocSupervisor().delegate = this;
  }

  AuthRepository get _authRepository => widget.authRepository;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(authRepository: _authRepository);

    Future.delayed(Duration(seconds: 3), () {
      _authenticationBloc.dispatch(AppStarted());
    });

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
        //showSemanticsDebugger: true,
        //routes: Routes.get(authRepository: _authRepository),
        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
          bloc: _authenticationBloc,
          builder: (BuildContext context, AuthenticationState state) {
            if (state is AuthenticationUninitialized) {
              return SplashScreen();
            } else if (state is AuthenticationPending) {
              return AuthenticationUserCodeScreen(
                verificationUrl: state.verificationUrl,
                userCode: state.userCode,
                expiresIn: state.expiresIn,
              );
            } else if (state is Authenticated) {
              return ProjectsScreen();
            } else if (state is AuthenticationFailed) {
              return AuthenticationFailureScreen();
            }
          },
        ),
        theme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Color(0xff1fe086),
          buttonColor: Color(0xff1fe086),
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 18.0),
            body2: TextStyle(fontSize: 18.0),
            subhead: TextStyle(fontSize: 18.0),
            button: TextStyle(fontSize: 18.0),
            caption: TextStyle(fontSize: 18.0),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
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

    if (error is AccessDeniedError) {
      _authenticationBloc.dispatch(AccessTokenExpired());
    }
  }
}
