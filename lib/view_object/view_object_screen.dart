import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/view_objects/view_objects.dart';
import '../view_object_parameters/view_object_parameters.dart';
import 'view_object.dart';

abstract class ViewObjectScreen<T extends ViewObjectBloc>
    extends StatefulWidget {
  final ViewObject viewObject;
  final String userToken;

  T get viewObjectBloc;

  ViewObjectScreen({
    Key key,
    @required this.viewObject,
    @required this.userToken,
  }) : super(key: key);
}

abstract class ViewObjectScreenState<T extends ViewObjectBloc>
    extends State<ViewObjectScreen> {
  ViewObject get _viewObject => widget.viewObject;
  String get _userToken => widget.userToken;
  T get _viewObjectBloc => widget.viewObjectBloc;

  Widget buildOutputWidget(ViewObjectGenerated state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_viewObject.title ?? _viewObject.name),
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _viewObjectBloc,
          builder: (BuildContext context, ViewObjectState state) {
            if (state is ViewObjectGeneration) {
              return CircularProgressIndicator();
            } else if (state is ViewObjectGenerated) {
              return buildOutputWidget(state);
            } else if (state is ViewObjectError) {
              return Text('Failed to generate view object');
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
                                viewObject: _viewObject, userToken: _userToken),
                          ),
                        );
                      },
                    ),
                    RaisedButton(
                      child: const Text('View'),
                      onPressed: () {
                        _viewObjectBloc.dispatch(GenerateViewObject(
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
    );
  }

  @override
  void dispose() {
    _viewObjectBloc.dispose();
    super.dispose();
  }
}
