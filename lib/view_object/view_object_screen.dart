import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:rits_client/models/projects/projects.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/view_object_parameters/view_object_parameters.dart';
import 'view_object.dart';

abstract class ViewObjectScreen extends StatefulWidget {
  final ViewObject viewObject;

  ViewObjectScreen({
    Key key,
    @required this.viewObject,
  })  : assert(viewObject != null),
        super(key: key);
}

abstract class ViewObjectScreenState<T extends ViewObjectBloc,
    S extends ViewObjectState> extends State<ViewObjectScreen> {
  ViewObject get viewObject => widget.viewObject;

  T viewObjectBloc;
  Widget buildOutputWidget(BuildContext context, S state);

  @override
  Widget build(BuildContext context) {
    final projectContext = Provider.of<ProjectContext>(context);

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(viewObject.title ?? viewObject.name),
        ),
        body: Center(
          child: BlocBuilder(
            bloc: viewObjectBloc,
            builder: (BuildContext context, ViewObjectState state) {
              //final projectContext = Provider.of<ProjectContext>(context);

              if (state is ViewObjectGeneration) {
                return CircularProgressIndicator();
              } else if (state is S) {
                return buildOutputWidget(context, state);
              } else if (state is ViewObjectError) {
                return const Text('Failed to generate view object');
              } else {
                return new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        child: const Text('View/Edit Parameters'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewObjectParametersScreen(
                                  viewObject: viewObject),
                            ),
                          );
                        },
                      ),
                      RaisedButton(
                        child: const Text('View'),
                        onPressed: () {
                          viewObjectBloc.dispatch(
                            GenerateViewObject(
                              viewObject,
                              projectContext.userToken,
                            ),
                          );
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

  bool returnToMainScreen() =>
      viewObjectBloc.currentState != viewObjectBloc.initialState;

  Future<bool> _onBackPressed() async {
    if (returnToMainScreen()) {
      viewObjectBloc.dispatch(ReturnToViewObjectMainScreen());

      return false;
    }

    return true;
  }
}
