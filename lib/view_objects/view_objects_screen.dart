import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/rest_client.dart';
import '../models/projects/projects.dart';
import 'view_objects.dart';

class ViewObjectsScreen<T extends ViewObjectsBloc> extends StatefulWidget {
  final Project project;
  final String detailsScreenRoute;
  final String type;
  final String userToken;
  final String hierarchyLevel;

  String get typePlural => '${type}s';

  ViewObjectsScreen({
    Key key,
    @required this.project,
    @required this.userToken,
    @required this.detailsScreenRoute,
    @required this.type,
    this.hierarchyLevel,
  }) : super(key: key);

  @override
  State createState() => _ViewObjectsScreenState();
}

class _ViewObjectsScreenState extends State<ViewObjectsScreen> {
  final ViewObjectsBloc _viewObjectsBloc =
      ViewObjectsBloc(restClient: RestClient());

  Project get _project => widget.project;
  String get _type => widget.type;
  String get _userToken => widget.userToken;
  String get _hierarchyLevel => widget.hierarchyLevel;

  @override
  void initState() {
    super.initState();
    _viewObjectsBloc.dispatch(FetchViewObjects(
      project: _project,
      type: _type,
      userToken: _userToken,
      hierarchyLevel: _hierarchyLevel,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_type),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: _viewObjectsBloc,
        builder: (BuildContext context, ViewObjectsState state) {
          if (state is ViewObjectsUninitialized) {
            return CircularProgressIndicator();
          } else if (state is ViewObjectsLoaded) {
            return BlocProvider(
              bloc: _viewObjectsBloc,
              child: _ViewObjectButtons(),
            );
          } else if (state is ViewObjectsError) {
            return const Text('Failed to fetch view objects');
          }
        },
      )),
    );
  }

  @override
  void dispose() {
    _viewObjectsBloc.dispose();
    super.dispose();
  }
}

class _ViewObjectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _viewObjectsBloc = BlocProvider.of<ViewObjectsBloc>(context);

    return BlocBuilder(
      bloc: _viewObjectsBloc,
      builder: (BuildContext context, ViewObjectsState state) {
        return Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 10,
          children: (state as ViewObjectsLoaded).viewObjects.map((viewObject) {
            final ViewObjectsScreen screen =
                context.ancestorWidgetOfExactType(ViewObjectsScreen);

            return RaisedButton(
                child: Text(viewObject.title ?? viewObject.name),
                onPressed: () async {
                  Navigator.pushNamed(
                    context,
                    screen.detailsScreenRoute,
                    arguments: {
                      'viewObject': viewObject,
                      'userToken': (state as ViewObjectsLoaded).userToken,
                    },
                  );
                });
          }).toList(),
        );
      },
    );
  }
}
