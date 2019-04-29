import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'utils/rest_client.dart';
import 'splash/splash.dart';
import 'projects/projects.dart';
import 'authentication/authentication.dart';
import 'login/login.dart';
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

void main() {
  final userRepository = UserRepository();

  BlocSupervisor().delegate = SimpleBlocDelegate();
  RestClient(userRepository: userRepository);
  runApp(RitsApp(userRepository: userRepository));
}

class RitsApp extends StatefulWidget {
  final UserRepository userRepository;

  RitsApp({Key key, @required this.userRepository}) : super(key: key);

//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'RITS Demo',
//      theme: ThemeData(
//        primarySwatch: Colors.green,
//      ),
//      home: ProjectsScreen(),
//      routes: routes,
//    );
//  }

  @override
  State<RitsApp> createState() => _RitsAppState();
}

class _RitsAppState extends State<RitsApp> {
  AuthenticationBloc _authenticationBloc;

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
            }
            if (state is AuthenticationAuthenticated) {
              return ProjectsScreen();
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginScreen(userRepository: _userRepository);
            }
            if (state is AuthenticationLoading) {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
