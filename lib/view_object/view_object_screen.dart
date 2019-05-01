import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object_parameters/view_object_parameters.dart';
import 'view_object.dart';

abstract class ViewObjectScreen extends StatefulWidget {
  final ViewObject viewObject;
  final String userToken;

  ViewObjectScreen({
    Key key,
    @required this.viewObject,
    @required this.userToken,
  }) : super(key: key);
}

abstract class ViewObjectScreenState<T extends ViewObjectBloc,
    S extends ViewObjectState> extends State<ViewObjectScreen> {
  ViewObject get _viewObject => widget.viewObject;
  String get _userToken => widget.userToken;

  T viewObjectBloc;
  Widget buildOutputWidget(S state);

  Future<bool> _onBackPressed() async {
    if (viewObjectBloc.currentState != viewObjectBloc.initialState) {
      viewObjectBloc.dispatch(ReturnToViewObjectMainScreen());

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_viewObject.title ?? _viewObject.name),
        ),
        body: Center(
          child: BlocBuilder(
            bloc: viewObjectBloc,
            builder: (BuildContext context, ViewObjectState state) {
              if (state is ViewObjectGeneration) {
                return CircularProgressIndicator();
              } else if (state is S) {
                return buildOutputWidget(state);
              } else if (state is ViewObjectError) {
                return const Text('Failed to generate view object');
              } else {
                return new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        child: const Text('View Parameters'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewObjectParametersScreen(
                                  viewObject: _viewObject,
                                  userToken: _userToken),
                            ),
                          );
                        },
                      ),
                      RaisedButton(
                        child: const Text('View'),
                        onPressed: () {
                          viewObjectBloc.dispatch(GenerateViewObject(
                            _viewObject,
                            _userToken,
                          ));
                        },
                      ),
                    ]);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewObjectBloc.dispose();
    super.dispose();
  }
}
