import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/projects/projects.dart';
import '../utils/rest_client.dart';
import '../reports/reports.dart';
import 'poi.dart';

class PoiScreen extends StatefulWidget {
  final Project project;
  final String userToken;

  PoiScreen({Key key, @required this.project, @required this.userToken})
      : super(key: key);

  @override
  State createState() => _PoiScreenState();
}

class _PoiScreenState extends State<PoiScreen> {
  final PoiBloc _poiBloc = PoiBloc(restClient: RestClient());

  Project get _project => widget.project;
  String get _userToken => widget.userToken;

  @override
  void initState() {
    super.initState();
    _poiBloc.dispatch(ScanItem(userToken: _userToken));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Bar Code'),
      ),
      body: Center(
          child: BlocBuilder(
        bloc: _poiBloc,
        builder: (BuildContext context, PoiState state) {
          if (state is PoiUninitialized) {
            return CircularProgressIndicator();
          } else if (state is ItemScanned) {
            return new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bar code content:\n${state.itemInfo}'),
                  RaisedButton(
                    child: const Text('Reports'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportsScreen(
                                project: _project,
                                userToken: _userToken,
                              ),
                        ),
                      );
                    },
                  ),
                ]);
          } else if (state is PoiError) {
            return Text(state.itemInfo);
          }
        },
      )),
    );
  }

  @override
  void dispose() {
    _poiBloc.dispose();
    super.dispose();
  }
}
