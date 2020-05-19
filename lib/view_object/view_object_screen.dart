import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rits_client/models/view_objects/view_objects.dart';
import 'package:rits_client/view_object_parameters/view_object_parameters.dart';

import 'view_object.dart';

abstract class ViewObjectScreen extends StatefulWidget {
  final ViewObject viewObject;
  final bool canBeFavorite;
  final bool fullScreen;

  ViewObjectScreen({
    Key key,
    @required this.viewObject,
    this.canBeFavorite = true,
    this.fullScreen = false,
  })  : assert(viewObject != null),
        super(key: key);
}

abstract class ViewObjectScreenState<T extends ViewObjectBloc,
    S extends ViewObjectState> extends State<ViewObjectScreen> {
  ViewObject get viewObject => widget.viewObject;
  bool get _canBeFavorite => widget.canBeFavorite;
  bool get _fullScreen => widget.fullScreen;

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
    return BlocBuilder(
        bloc: bloc,
        builder: (BuildContext context, ViewObjectState state) {
          Widget bodyChild = SizedBox.shrink();

          if (state is ViewObjectUninitialized) {
            bodyChild = CircularProgressIndicator();
          } else if (state is ViewObjectIdle) {
            bodyChild =
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Visibility(
                visible: state.hasParams,
                child: RaisedButton(
                  child: const Text('View/Edit Parameters'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewObjectParametersScreen(viewObject: viewObject),
                      ),
                    );
                  },
                ),
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
                        ? bloc.add(RemoveFavorite(viewObject, state.favoriteId))
                        : bloc.add(AddFavorite(viewObject));
                  },
                ),
              ),
            ]);
          } else if (state is ViewObjectGeneration) {
            bodyChild = CircularProgressIndicator();
          } else if (state is S) {
            bodyChild = buildOutputWidget(context, state);
          } else if (state is ViewObjectError) {
            bodyChild = const Text('Failed to generate view object');
          }

          return WillPopScope(
            onWillPop: _onBackPressed,
            child: Scaffold(
              appBar: !(_fullScreen && state is S)
                  ? AppBar(
                      title: Text(viewObject.title ?? viewObject.name),
                    )
                  : null,
              body: Center(
                child: bodyChild,
              ),
            ),
          );
        });
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
