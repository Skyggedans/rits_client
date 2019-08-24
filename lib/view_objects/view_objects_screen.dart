import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../models/projects/projects.dart';
import '../utils/utils.dart';
import 'view_objects.dart';

class ViewObjectsScreen<T extends ViewObjectsBloc> extends StatefulWidget {
  final String detailsScreenRoute;
  final String title;
  final String type;
  final ViewObjectsRepository viewObjectsRepository;

  ViewObjectsScreen({
    Key key,
    @required this.detailsScreenRoute,
    this.title,
    this.type,
    this.viewObjectsRepository,
  })  : assert(detailsScreenRoute != null),
        assert(type != null),
        super(key: key);

  @override
  State createState() => _ViewObjectsScreenState(viewObjectsRepository);
}

class _ViewObjectsScreenState extends State<ViewObjectsScreen> {
  final ViewObjectsBloc viewObjectsBloc;

  String get _title => widget.title;
  String get _type => widget.type;

  _ViewObjectsScreenState._({this.viewObjectsBloc});

  factory _ViewObjectsScreenState(ViewObjectsRepository viewObjectsRepository) {
    return _ViewObjectsScreenState._(
      viewObjectsBloc: ViewObjectsBloc(
          viewObjectsRepository: viewObjectsRepository ??
              ViewObjectsRepository(restClient: RestClient())),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (viewObjectsBloc.currentState == viewObjectsBloc.initialState) {
      final projectContext = Provider.of<ProjectContext>(context);

      viewObjectsBloc.dispatch(FetchViewObjects(
        type: _type,
        project: projectContext.project,
        userToken: projectContext.userToken,
        hierarchyLevel: projectContext.hierarchyLevel,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title ?? _type),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: viewObjectsBloc,
        builder: (BuildContext context, ViewObjectsState state) {
          if (state is ViewObjectsUninitialized) {
            return CircularProgressIndicator();
          } else if (state is ViewObjectsLoaded) {
            return BlocProvider(
              bloc: viewObjectsBloc,
              child: _ViewObjectButtons(),
            );
          } else if (state is ViewObjectsError) {
            return Text('Failed to fetch ${_title ?? _type}');
          }
        },
      )),
    );
  }

  @override
  void dispose() {
    viewObjectsBloc.dispose();
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
                  final projectContext = Provider.of<ProjectContext>(context);

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
