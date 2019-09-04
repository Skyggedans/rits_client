import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'authentication/authentication.dart';
import 'projects/projects.dart';
import 'splash/splash.dart';

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
  HttpOverrides.global = _HttpOverrides();

  // RwSpeechRecognizer.setCommands(<String>['Test'], (command) {
  //   command;
  // });

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationBloc>(
          builder: (_) => AuthenticationBloc(),
          dispose: (context, value) => value.dispose(),
        )
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
  _RitsAppState() {
    BlocSupervisor().delegate = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authenticationBloc = Provider.of<AuthenticationBloc>(context);

    if (authenticationBloc.currentState == authenticationBloc.initialState) {
      Future.delayed(Duration(seconds: 3), () {
        authenticationBloc.dispatch(AppStarted());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationBloc>(
      builder: (context, bloc, child) {
        return MaterialApp(
          //showSemanticsDebugger: true,
          home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
            bloc: bloc,
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
                return _ProjectsBlocProvider(
                  child: ProjectsScreen(),
                );
              }

              return AuthenticationFailureScreen();
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
  void onTransition(Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);

    if (error is AccessDeniedError) {
      Provider.of<AuthenticationBloc>(context).dispatch(AccessTokenExpired());
    }
  }
}

class _ProjectsBlocProvider extends MultiProvider {
  _ProjectsBlocProvider({@required Widget child})
      : super(
          providers: [
            Provider<ProjectsDao>.value(value: ProjectsDao()),
            ProxyProvider<ProjectsDao, ProjectsRepository>(
              builder: (_, projectsDao, __) =>
                  ProjectsRepository(projectsDao: projectsDao),
            ),
            ProxyProvider<ProjectsRepository, ProjectsBloc>(
              builder: (_, projectsRepository, __) =>
                  ProjectsBloc(projectsRepository: projectsRepository),
              dispose: (_, value) => value.dispose(),
            )
          ],
          child: child,
        );
}
