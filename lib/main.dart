import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/app_config.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:path/path.dart' as path;

import 'authentication/authentication.dart';
import 'projects/projects.dart';
import 'routes.dart';
import 'splash/splash.dart';
import 'utils/rest_client.dart';

final _logger = Logger('main');

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
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  final authRepository = AuthRepository(authProvider: AuthProvider());

  HttpOverrides.global = _HttpOverrides();
  RestClient(authRepository: authRepository);

  Logger.root.level = Level.ALL;
  PrintAppender()..attachToLogger(Logger.root);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    RotatingFileAppender(
        baseFilePath: path.join(Directory.current.path, 'logs', 'rits.log'))
      ..attachToLogger(Logger.root);
  }

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
    BlocSupervisor.delegate = this;
  }

  AuthRepository get _authRepository => widget.authRepository;

  @override
  void initState() {
    _authenticationBloc = AuthenticationBloc(authRepository: _authRepository);

    Future.delayed(Duration(seconds: 3), () {
      _authenticationBloc.add(AppStarted());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (context) => _authenticationBloc,
      child: MaterialApp(
        //showSemanticsDebugger: true,
        routes: Routes.get(authRepository: _authRepository),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
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
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    _logger.info(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.info(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    _logger.severe('$error, $stacktrace');
  }
}
