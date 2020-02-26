import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/view_object_parameters/view_object_parameters.dart';

import 'view_object.dart';

abstract class ViewObjectScreen extends StatefulWidget {
  final ViewObject viewObject;
  final bool canBeFavorite;
  final bool hideAppBar;

  ViewObjectScreen({
    Key key,
    @required this.viewObject,
    this.canBeFavorite = true,
    this.hideAppBar = false,
  })  : assert(viewObject != null),
        super(key: key);
}

abstract class ViewObjectScreenState<T extends ViewObjectBloc,
    S extends ViewObjectState> extends State<ViewObjectScreen> {
  ViewObject get viewObject => widget.viewObject;
  bool get _canBeFavorite => widget.canBeFavorite;
  bool get _hideAppBar => widget.hideAppBar;

  T bloc;
  Widget buildOutputWidget(BuildContext context, S state);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (bloc == null) {
      bloc = createBloc()..add(GetFavoriteId(viewObject));
    }
  }

  @override
  void dispose() {
    bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: !_hideAppBar
            ? AppBar(
                title: Text(viewObject.title ?? viewObject.name),
              )
            : null,
        body: Center(
          child: BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, ViewObjectState state) {
              if (state is ViewObjectUninitialized) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ViewObjectIdle) {
                return Column(
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
                          bloc.add(GenerateViewObject(viewObject));
                        },
                      ),
                      Visibility(
                        visible: _canBeFavorite,
                        child: RaisedButton(
                          child: Text(state.favoriteId > 0
                              ? 'Remove Favorite'
                              : 'Add Favorite'),
                          onPressed: () {
                            state.favoriteId > 0
                                ? bloc.add(RemoveFavorite(state.favoriteId))
                                : bloc.add(AddFavorite(viewObject));
                          },
                        ),
                      ),
                    ]);
              } else if (state is ViewObjectGeneration) {
                return CircularProgressIndicator();
              } else if (state is S) {
                return buildOutputWidget(context, state);
              } else if (state is ViewObjectError) {
                return const Text('Failed to generate view object');
              }

              return null;
            },
          ),
        ),
      ),
    );
  }

  bool returnToMainScreen() => !(bloc.state is ViewObjectIdle);

  T createBloc();

  Future<bool> _onBackPressed() async {
    if (returnToMainScreen()) {
      bloc.add(ReturnToViewObjectMainScreen(viewObject));

      return false;
    }

    return true;
  }
}
