import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:path/path.dart' as path;
import 'package:rits_client/app_context.dart';

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

  Provider.debugCheckInvalidValueType = null;
  HttpOverrides.global = _HttpOverrides();

  Logger.root.level = Level.ALL;
  PrintAppender()..attachToLogger(Logger.root);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    RotatingFileAppender(
        baseFilePath: path.join(Directory.current.path, 'logs', 'rits.log'))
      ..attachToLogger(Logger.root);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>(
          create: (_) => AppConfig(),
        ),
        InheritedProvider<AppContext>(
          create: (_) => AppContext(),
        ),
        Provider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ProxyProvider<AuthProvider, AuthRepository>(
          update: (_, authProvider, __) =>
              AuthRepository(authProvider: authProvider),
        ),
        ProxyProvider<AuthRepository, RestClient>(
          update: (_, authRepository, __) =>
              RestClient(authRepository: authRepository),
        ),
        ProxyProvider<AuthRepository, AuthenticationBloc>(
          update: (_, authRepository, __) =>
              AuthenticationBloc(authRepository: authRepository),
          dispose: (_, bloc) => bloc.close(),
        ),
      ],
      child: RitsApp(),
    ),
  );
}

class RitsApp extends StatefulWidget {
  RitsApp({Key key}) : super(key: key);

  @override
  State<RitsApp> createState() => _RitsAppState();
}

class _RitsAppState extends State<RitsApp> with BlocDelegate {
  _RitsAppState() {
    BlocSupervisor.delegate = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authenticationBloc = Provider.of<AuthenticationBloc>(context);

    Future.delayed(Duration(seconds: 3), () {
      authenticationBloc.add(AppStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, AuthenticationBloc>(
      builder: (context, authRepository, authenticationBloc, _) {
        return MaterialApp(
          //showSemanticsDebugger: true,
          routes: Routes.get(authRepository: authRepository),
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            bloc: authenticationBloc,
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
                return ProxyProvider<RestClient, ProjectsBloc>(
                  update: (_, restClient, __) =>
                      ProjectsBloc(restClient: restClient),
                  //..add(FetchProjects()),
                  dispose: (_, bloc) => bloc.close(),
                  child: ProjectsScreen(),
                );
              } else if (state is AuthenticationFailed) {
                return AuthenticationFailureScreen();
              }

              return null;
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
        );
      },
    );
  }

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    _logger.info('${bloc.runtimeType}: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.info('${bloc.runtimeType}: $transition');
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    _logger.severe('${bloc.runtimeType}: $error, $stacktrace');
  }
}
