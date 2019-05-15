import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../authentication/authentication.dart';
import '../user_repository/user_repository.dart';
import './login.dart';

class LoginScreen extends StatefulWidget {
  final UserRepository userRepository;

  LoginScreen({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _userRepository,
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: LoginForm(
          authenticationBloc: _authenticationBloc,
          loginBloc: _loginBloc,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }
}
