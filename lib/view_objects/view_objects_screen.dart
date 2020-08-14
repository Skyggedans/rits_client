import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rits_client/app_context.dart';
import 'package:rits_client/utils/utils.dart';

import 'view_objects.dart';

class ViewObjectsScreen<T extends ViewObjectsBloc> extends StatefulWidget {
  final String detailsScreenRoute;
  final String title;
  final String type;
  final bool favorite;

  ViewObjectsScreen({
    Key key,
    @required this.detailsScreenRoute,
    this.title,
    this.type,
    this.favorite = false,
  })  : assert(detailsScreenRoute != null),
        super(key: key);

  @override
  State createState() => _ViewObjectsScreenState();
}

class _ViewObjectsScreenState extends State<ViewObjectsScreen> {
  ViewObjectsBloc bloc;

  String get _title => widget.title;
  String get _type => widget.type;
  bool get _favorite => widget.favorite;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (bloc == null) {
      final appContext = Provider.of<AppContext>(context);
      final viewObjectsRepository = Provider.of<ViewObjectsRepository>(context);

      bloc = ViewObjectsBloc(
        appContext: appContext,
        viewObjectsRepository: viewObjectsRepository ??
            ViewObjectsRepository(
              restClient: Provider.of<RestClient>(context),
              appContext: appContext,
            ),
      )..add(FetchViewObjects(
          type: _type,
          favorite: _favorite,
        ));
    }
  }

  @override
  void dispose() {
    bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title ?? _type),
      ),
      body: Center(
          child: BlocBuilder(
        cubit: bloc,
        builder: (BuildContext context, ViewObjectsState state) {
          if (state is ViewObjectsUninitialized) {
            return CircularProgressIndicator();
          } else if (state is ViewObjectsLoaded) {
            return Provider.value(
              value: bloc,
              child: _ViewObjectButtons(),
            );
          }

          return const Text('Failed to fetch view objects');
        },
      )),
    );
  }
}

class _ViewObjectButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = Provider.of<ViewObjectsBloc>(context);

    return BlocBuilder(
      cubit: _bloc,
      builder: (BuildContext context, ViewObjectsState state) {
        return Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 10,
          children: (state as ViewObjectsLoaded).viewObjects.map((viewObject) {
            final ViewObjectsScreen screen =
                context.findAncestorWidgetOfExactType<ViewObjectsScreen>();

            return RaisedButton(
                child: Text(viewObject.title ?? viewObject.name),
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    screen.detailsScreenRoute,
                    arguments: {'viewObject': viewObject},
                  );
                });
          }).toList(),
        );
      },
    );
  }
}
