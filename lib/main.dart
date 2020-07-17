import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:rits_client/app_config.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/view_objects/view_objects.dart';
import 'package:flutter/services.dart';

import 'auth/auth.dart';
import 'projects/projects.dart';
import 'routes.dart';
import 'splash/splash.dart';
import 'utils/rest_client.dart';

final _appConfig = AppConfig();
final _appContext = AppContext();
final _authProvider = AuthProvider();
final _authRepository = AuthRepository(authProvider: _authProvider);
final _restClient = RestClient(authRepository: _authRepository);
final _authBloc =
    AuthBloc(authRepository: _authRepository, analytics: _analytics);
final _viewObjectsRepository =
    ViewObjectsRepository(restClient: _restClient, appContext: _appContext);
final _logger = Logger('main');
final _analytics = FirebaseAnalytics();

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
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);

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

  if (Platform.isAndroid || Platform.isIOS) {
    FlutterDownloader.initialize(
      debug: true,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(
          value: _appConfig,
        ),
        Provider<AppContext>.value(
          value: _appContext,
        ),
        Provider<AuthProvider>.value(
          value: _authProvider,
        ),
        Provider<AuthRepository>.value(
          value: _authRepository,
        ),
        Provider<RestClient>.value(
          value: _restClient,
        ),
        Provider<AuthBloc>.value(
          value: _authBloc,
        ),
        Provider<ViewObjectsRepository>.value(
          value: _viewObjectsRepository,
        ),
        Provider<FirebaseAnalytics>.value(value: _analytics),
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

    final authBloc = Provider.of<AuthBloc>(context);

    if (authBloc.state is AuthUninitialized) {
      Future.delayed(Duration(seconds: 3), () {
        authBloc.add(AppStarted());
      });
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, AuthBloc>(
      builder: (context, authRepository, authenticationBloc, _) {
        return MaterialApp(
          //showSemanticsDebugger: true,
          routes: Routes.get(),
          home: BlocBuilder<AuthBloc, AuthState>(
            bloc: authenticationBloc,
            builder: (BuildContext context, AuthState state) {
              if (state is AuthUninitialized) {
                return SplashScreen();
              } else if (state is AuthReinitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                });
              } else if (state is AuthPending) {
                return AuthUserCodeScreen(
                  verificationUrl: state.verificationUrl,
                  userCode: state.userCode,
                  expiresIn: state.expiresIn,
                );
              } else if (state is Authenticated) {
                return ProjectsScreen();
              } else if (state is AuthFailed) {
                return AuthFailureScreen();
              }

              return SizedBox.shrink();
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

    if (error is AccessDeniedError) {
      _authBloc.add(AccessTokenExpired());

      return;
    }

    _logger.severe('${bloc.runtimeType}: $error, $stacktrace');

    _analytics.logEvent(
      name: 'Bloc Error',
      parameters: {
        'bloc': bloc.runtimeType,
        'error': error,
        'stacktrace': stacktrace,
      },
    );
  }
}
