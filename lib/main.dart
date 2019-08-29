import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'authentication/authentication.dart';
import 'models/app_config.dart';
import 'projects/projects.dart';
import 'settings.dart';
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
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: AppConfig(settings: Settings())),
        Provider<AuthRepository>.value(value: authRepository),
      ],
      child: RitsApp(),
    ),
  );
}

class RitsApp extends StatefulWidget {
  @override
  State<RitsApp> createState() => _RitsAppState();
}

class _RitsAppState extends State<RitsApp> with BlocDelegate {
  AuthenticationBloc _authenticationBloc;

  _RitsAppState() {
    BlocSupervisor().delegate = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_authenticationBloc == null) {
      final authRepository = Provider.of<AuthRepository>(context);

      _authenticationBloc = AuthenticationBloc(authRepository: authRepository);

      Future.delayed(Duration(seconds: 3), () {
        _authenticationBloc.dispatch(AppStarted());
      });
    }
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
